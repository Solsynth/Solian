#include "include/island_desktop_presence/island_desktop_presence_plugin.h"

#include <X11/Xlib.h>
#include <X11/extensions/scrnsaver.h>
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>

#include "island_desktop_presence_plugin_private.h"

#define ISLAND_DESKTOP_PRESENCE_PLUGIN(obj)                           \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), island_desktop_presence_plugin_get_type(), \
                              IslandDesktopPresencePlugin))

struct _IslandDesktopPresencePlugin {
  GObject parent_instance;

  FlEventChannel* event_channel;
  gboolean is_listening;
  guint timer_id;
  gint64 idle_threshold_milliseconds;
  gboolean has_last_state;
  gboolean last_state_idle;
  FlValue* pending_event;
  Display* display;
};

G_DEFINE_TYPE(IslandDesktopPresencePlugin,
              island_desktop_presence_plugin,
              g_object_get_type())

namespace {

constexpr char kMethodChannelName[] = "island_desktop_presence";
constexpr char kEventChannelName[] = "island_desktop_presence/events";

FlMethodResponse* success_response_from_value(FlValue* value) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(value));
}

gboolean query_idle_milliseconds(IslandDesktopPresencePlugin* self,
                                 gint64* idle_milliseconds) {
  if (self->display == nullptr) {
    self->display = XOpenDisplay(nullptr);
  }

  if (self->display == nullptr) {
    return FALSE;
  }

  int event_base = 0;
  int error_base = 0;
  if (!XScreenSaverQueryExtension(self->display, &event_base, &error_base)) {
    return FALSE;
  }

  XScreenSaverInfo* info = XScreenSaverAllocInfo();
  if (info == nullptr) {
    return FALSE;
  }

  const Window root = DefaultRootWindow(self->display);
  const Status status =
      XScreenSaverQueryInfo(self->display, root, info);
  if (status == 0) {
    XFree(info);
    return FALSE;
  }

  *idle_milliseconds = static_cast<gint64>(info->idle);
  XFree(info);
  return TRUE;
}

FlValue* build_event(gboolean is_idle, gint64 idle_milliseconds) {
  FlValue* event = fl_value_new_map();
  fl_value_set_string_take(
      event, "state",
      fl_value_new_string(is_idle ? "idle" : "active"));
  fl_value_set_string_take(
      event, "idle_seconds",
      fl_value_new_int(static_cast<int64_t>(idle_milliseconds / 1000)));
  return event;
}

void emit_current_state(IslandDesktopPresencePlugin* self, gboolean force) {
  gint64 idle_milliseconds = 0;
  if (!query_idle_milliseconds(self, &idle_milliseconds)) {
    return;
  }

  const gboolean is_idle =
      idle_milliseconds >= self->idle_threshold_milliseconds;
  if (!force && self->has_last_state && self->last_state_idle == is_idle) {
    return;
  }

  self->has_last_state = TRUE;
  self->last_state_idle = is_idle;

  g_autoptr(FlValue) event = build_event(is_idle, idle_milliseconds);
  if (self->is_listening) {
    g_autoptr(GError) error = nullptr;
    fl_event_channel_send(self->event_channel, event, nullptr, &error);
    return;
  }

  g_clear_pointer(&self->pending_event, fl_value_unref);
  self->pending_event = fl_value_ref(event);
}

gboolean poll_presence(gpointer user_data) {
  auto* self = ISLAND_DESKTOP_PRESENCE_PLUGIN(user_data);
  emit_current_state(self, FALSE);
  return G_SOURCE_CONTINUE;
}

void stop_monitoring(IslandDesktopPresencePlugin* self, gboolean reset_state) {
  if (self->timer_id != 0) {
    g_source_remove(self->timer_id);
    self->timer_id = 0;
  }

  if (reset_state) {
    self->has_last_state = FALSE;
    g_clear_pointer(&self->pending_event, fl_value_unref);
  }
}

void start_monitoring(IslandDesktopPresencePlugin* self) {
  stop_monitoring(self, FALSE);
  self->timer_id = g_timeout_add_seconds(3, poll_presence, self);
}

FlMethodErrorResponse* event_listen_cb(FlEventChannel* channel,
                                       FlValue* args,
                                       gpointer user_data) {
  auto* self = ISLAND_DESKTOP_PRESENCE_PLUGIN(user_data);
  self->is_listening = TRUE;

  if (self->pending_event != nullptr) {
    g_autoptr(GError) error = nullptr;
    fl_event_channel_send(self->event_channel, self->pending_event, nullptr,
                          &error);
    g_clear_pointer(&self->pending_event, fl_value_unref);
  }

  return nullptr;
}

FlMethodErrorResponse* event_cancel_cb(FlEventChannel* channel,
                                       FlValue* args,
                                       gpointer user_data) {
  auto* self = ISLAND_DESKTOP_PRESENCE_PLUGIN(user_data);
  self->is_listening = FALSE;
  return nullptr;
}

}  // namespace

FlMethodResponse* get_idle_time_response(gint64 idle_milliseconds) {
  g_autoptr(FlValue) result = fl_value_new_int(idle_milliseconds);
  return success_response_from_value(result);
}

static void island_desktop_presence_plugin_handle_method_call(
    IslandDesktopPresencePlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getIdleTime") == 0) {
    gint64 idle_milliseconds = 0;
    if (!query_idle_milliseconds(self, &idle_milliseconds)) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "idle_unavailable",
          "X11 idle detection is not available on this system.", nullptr));
    } else {
      response = get_idle_time_response(idle_milliseconds);
    }
  } else if (strcmp(method, "startMonitoring") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "invalid_arguments", "Expected startMonitoring arguments.", nullptr));
    } else {
      FlValue* threshold_value =
          fl_value_lookup_string(args, "idleThresholdMilliseconds");
      if (threshold_value == nullptr ||
          fl_value_get_type(threshold_value) != FL_VALUE_TYPE_INT) {
        response = FL_METHOD_RESPONSE(fl_method_error_response_new(
            "invalid_arguments",
            "idleThresholdMilliseconds must be a non-negative integer.",
            nullptr));
      } else {
        const gint64 threshold = fl_value_get_int(threshold_value);
        if (threshold < 0) {
          response = FL_METHOD_RESPONSE(fl_method_error_response_new(
              "invalid_arguments",
              "idleThresholdMilliseconds must be a non-negative integer.",
              nullptr));
        } else {
          self->idle_threshold_milliseconds = threshold;
          start_monitoring(self);
          emit_current_state(self, TRUE);
          response =
              FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
        }
      }
    }
  } else if (strcmp(method, "stopMonitoring") == 0) {
    stop_monitoring(self, TRUE);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void island_desktop_presence_plugin_dispose(GObject* object) {
  auto* self = ISLAND_DESKTOP_PRESENCE_PLUGIN(object);
  stop_monitoring(self, TRUE);
  g_clear_pointer(&self->pending_event, fl_value_unref);
  g_clear_object(&self->event_channel);
  if (self->display != nullptr) {
    XCloseDisplay(self->display);
    self->display = nullptr;
  }

  G_OBJECT_CLASS(island_desktop_presence_plugin_parent_class)->dispose(object);
}

static void island_desktop_presence_plugin_class_init(
    IslandDesktopPresencePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = island_desktop_presence_plugin_dispose;
}

static void island_desktop_presence_plugin_init(
    IslandDesktopPresencePlugin* self) {
  self->idle_threshold_milliseconds = 300000;
}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  auto* plugin = ISLAND_DESKTOP_PRESENCE_PLUGIN(user_data);
  island_desktop_presence_plugin_handle_method_call(plugin, method_call);
}

void island_desktop_presence_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  auto* plugin = ISLAND_DESKTOP_PRESENCE_PLUGIN(
      g_object_new(island_desktop_presence_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) method_channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            kMethodChannelName, FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(method_channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  plugin->event_channel = fl_event_channel_new(
      fl_plugin_registrar_get_messenger(registrar), kEventChannelName,
      FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(plugin->event_channel, event_listen_cb,
                                       event_cancel_cb, g_object_ref(plugin),
                                       g_object_unref);

  g_object_unref(plugin);
}
