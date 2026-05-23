#include "include/island_desktop_presence/island_desktop_presence_plugin.h"

#include <X11/Xlib.h>
#include <X11/extensions/scrnsaver.h>
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#include <atomic>
#include <cerrno>
#include <cstring>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#include "island_desktop_presence_plugin_private.h"

#define ISLAND_DESKTOP_PRESENCE_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), island_desktop_presence_plugin_get_type(), \
                              IslandDesktopPresencePlugin))

struct LinuxRpcConnection {
  std::string connection_id;
  int fd = -1;
  std::vector<uint8_t> buffer;
};

struct LinuxRpcState {
  std::atomic_bool running = false;
  int server_fd = -1;
  std::string socket_path;
  std::thread accept_thread;
  std::mutex mutex;
  uint64_t next_connection_id = 1;
  std::map<std::string, std::shared_ptr<LinuxRpcConnection>> connections;
};

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

  FlEventChannel* rpc_event_channel;
  gboolean rpc_is_listening;
  GPtrArray* pending_rpc_events;
  LinuxRpcState* rpc_state;
};

G_DEFINE_TYPE(IslandDesktopPresencePlugin,
              island_desktop_presence_plugin,
              g_object_get_type())

namespace {

constexpr char kMethodChannelName[] = "island_desktop_presence";
constexpr char kEventChannelName[] = "island_desktop_presence/events";
constexpr char kRpcEventChannelName[] = "island_desktop_presence/rpc_events";
constexpr size_t kRpcReadBufferSize = 4096;

struct PendingRpcEventData {
  IslandDesktopPresencePlugin* plugin;
  FlValue* event;
};

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
  const Status status = XScreenSaverQueryInfo(self->display, root, info);
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

std::vector<uint8_t> encode_rpc_packet(int32_t packet_type,
                                       const std::string& data_json) {
  std::vector<uint8_t> packet(8 + data_json.size());
  std::memcpy(packet.data(), &packet_type, sizeof(int32_t));
  const int32_t payload_size = static_cast<int32_t>(data_json.size());
  std::memcpy(packet.data() + 4, &payload_size, sizeof(int32_t));
  std::memcpy(packet.data() + 8, data_json.data(), data_json.size());
  return packet;
}

gboolean deliver_pending_rpc_event(gpointer user_data) {
  auto* pending = static_cast<PendingRpcEventData*>(user_data);
  auto* plugin = pending->plugin;

  if (plugin->rpc_is_listening) {
    g_autoptr(GError) error = nullptr;
    fl_event_channel_send(plugin->rpc_event_channel, pending->event, nullptr,
                          &error);
  } else {
    g_ptr_array_add(plugin->pending_rpc_events, fl_value_ref(pending->event));
  }

  fl_value_unref(pending->event);
  delete pending;
  return G_SOURCE_REMOVE;
}

void queue_rpc_event(IslandDesktopPresencePlugin* plugin, FlValue* event) {
  auto* pending = new PendingRpcEventData{
      plugin,
      fl_value_ref(event),
  };
  g_main_context_invoke(nullptr, deliver_pending_rpc_event, pending);
}

void emit_rpc_connected(IslandDesktopPresencePlugin* plugin,
                        const std::string& connection_id) {
  g_autoptr(FlValue) event = fl_value_new_map();
  fl_value_set_string_take(event, "event", fl_value_new_string("connected"));
  fl_value_set_string_take(event, "connection_id",
                           fl_value_new_string(connection_id.c_str()));
  queue_rpc_event(plugin, event);
}

void emit_rpc_packet(IslandDesktopPresencePlugin* plugin,
                     const std::string& connection_id,
                     int32_t packet_type,
                     const std::string& data_json) {
  g_autoptr(FlValue) event = fl_value_new_map();
  fl_value_set_string_take(event, "event", fl_value_new_string("packet"));
  fl_value_set_string_take(event, "connection_id",
                           fl_value_new_string(connection_id.c_str()));
  fl_value_set_string_take(event, "packet_type",
                           fl_value_new_int(packet_type));
  fl_value_set_string_take(event, "data_json",
                           fl_value_new_string(data_json.c_str()));
  queue_rpc_event(plugin, event);
}

void emit_rpc_closed(IslandDesktopPresencePlugin* plugin,
                     const std::string& connection_id) {
  g_autoptr(FlValue) event = fl_value_new_map();
  fl_value_set_string_take(event, "event", fl_value_new_string("closed"));
  fl_value_set_string_take(event, "connection_id",
                           fl_value_new_string(connection_id.c_str()));
  queue_rpc_event(plugin, event);
}

void emit_rpc_error(IslandDesktopPresencePlugin* plugin,
                    const std::string& message) {
  g_autoptr(FlValue) event = fl_value_new_map();
  fl_value_set_string_take(event, "event", fl_value_new_string("error"));
  fl_value_set_string_take(event, "message",
                           fl_value_new_string(message.c_str()));
  queue_rpc_event(plugin, event);
}

std::string find_available_rpc_socket_path() {
  std::vector<std::string> base_dirs;
  const char* runtime_dir = g_getenv("XDG_RUNTIME_DIR");
  const char* tmp_dir = g_getenv("TMPDIR");
  const char* temp_dir = g_getenv("TEMP");

  if (runtime_dir != nullptr && std::strlen(runtime_dir) > 0) {
    base_dirs.emplace_back(runtime_dir);
  }
  if (tmp_dir != nullptr && std::strlen(tmp_dir) > 0) {
    base_dirs.emplace_back(tmp_dir);
  }
  if (temp_dir != nullptr && std::strlen(temp_dir) > 0) {
    base_dirs.emplace_back(temp_dir);
  }
  base_dirs.emplace_back(g_get_tmp_dir());

  for (const auto& base_dir : base_dirs) {
    for (int i = 0; i < 10; ++i) {
      const std::string candidate =
          base_dir + G_DIR_SEPARATOR_S + "discord-ipc-" + std::to_string(i);
      const int fd = socket(AF_UNIX, SOCK_STREAM, 0);
      if (fd < 0) {
        continue;
      }

      sockaddr_un address = {};
      address.sun_family = AF_UNIX;
      std::strncpy(address.sun_path, candidate.c_str(),
                   sizeof(address.sun_path) - 1);
      unlink(candidate.c_str());
      const int result =
          bind(fd, reinterpret_cast<sockaddr*>(&address), sizeof(address));
      if (result == 0) {
        close(fd);
        unlink(candidate.c_str());
        return candidate;
      }

      close(fd);
    }
  }

  return "";
}

void read_rpc_connection(IslandDesktopPresencePlugin* plugin,
                         std::shared_ptr<LinuxRpcConnection> connection) {
  std::vector<uint8_t> read_buffer(kRpcReadBufferSize);

  while (plugin->rpc_state->running) {
    const ssize_t bytes_read =
        recv(connection->fd, read_buffer.data(), read_buffer.size(), 0);
    if (bytes_read <= 0) {
      break;
    }

    connection->buffer.insert(connection->buffer.end(), read_buffer.begin(),
                              read_buffer.begin() + bytes_read);

    while (connection->buffer.size() >= 8) {
      int32_t packet_type = 0;
      int32_t payload_size = 0;
      std::memcpy(&packet_type, connection->buffer.data(), sizeof(int32_t));
      std::memcpy(&payload_size, connection->buffer.data() + 4,
                  sizeof(int32_t));

      if (payload_size < 0 ||
          connection->buffer.size() <
              static_cast<size_t>(8 + payload_size)) {
        break;
      }

      const std::string payload(connection->buffer.begin() + 8,
                                connection->buffer.begin() + 8 + payload_size);
      connection->buffer.erase(connection->buffer.begin(),
                               connection->buffer.begin() + 8 + payload_size);
      emit_rpc_packet(plugin, connection->connection_id, packet_type, payload);
    }
  }

  {
    std::lock_guard<std::mutex> lock(plugin->rpc_state->mutex);
    plugin->rpc_state->connections.erase(connection->connection_id);
  }
  close(connection->fd);
  emit_rpc_closed(plugin, connection->connection_id);
}

void accept_rpc_connections(IslandDesktopPresencePlugin* plugin) {
  while (plugin->rpc_state->running) {
    const int client_fd = accept(plugin->rpc_state->server_fd, nullptr, nullptr);
    if (client_fd < 0) {
      if (!plugin->rpc_state->running) {
        return;
      }
      if (errno == EINTR) {
        continue;
      }
      emit_rpc_error(plugin, "Failed to accept RPC socket connection.");
      continue;
    }

    auto connection = std::make_shared<LinuxRpcConnection>();
    connection->fd = client_fd;
    {
      std::lock_guard<std::mutex> lock(plugin->rpc_state->mutex);
      connection->connection_id =
          std::to_string(plugin->rpc_state->next_connection_id++);
      plugin->rpc_state->connections[connection->connection_id] = connection;
    }

    emit_rpc_connected(plugin, connection->connection_id);
    std::thread([plugin, connection]() {
      read_rpc_connection(plugin, connection);
    }).detach();
  }
}

bool start_rpc_transport(IslandDesktopPresencePlugin* plugin,
                         std::string* error_message) {
  if (plugin->rpc_state->running) {
    return true;
  }

  const std::string socket_path = find_available_rpc_socket_path();
  if (socket_path.empty()) {
    *error_message = "No available Discord IPC socket path found.";
    return false;
  }

  const int server_fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (server_fd < 0) {
    *error_message = "Failed to create RPC socket.";
    return false;
  }

  sockaddr_un address = {};
  address.sun_family = AF_UNIX;
  std::strncpy(address.sun_path, socket_path.c_str(),
               sizeof(address.sun_path) - 1);
  unlink(socket_path.c_str());

  if (bind(server_fd, reinterpret_cast<sockaddr*>(&address), sizeof(address)) !=
      0) {
    *error_message = "Failed to bind RPC socket.";
    close(server_fd);
    return false;
  }

  if (listen(server_fd, 8) != 0) {
    *error_message = "Failed to listen on RPC socket.";
    close(server_fd);
    unlink(socket_path.c_str());
    return false;
  }

  plugin->rpc_state->server_fd = server_fd;
  plugin->rpc_state->socket_path = socket_path;
  plugin->rpc_state->running = true;
  plugin->rpc_state->accept_thread =
      std::thread([plugin]() { accept_rpc_connections(plugin); });
  return true;
}

void stop_rpc_transport(IslandDesktopPresencePlugin* plugin) {
  if (!plugin->rpc_state->running) {
    return;
  }

  plugin->rpc_state->running = false;
  if (plugin->rpc_state->server_fd >= 0) {
    shutdown(plugin->rpc_state->server_fd, SHUT_RDWR);
    close(plugin->rpc_state->server_fd);
    plugin->rpc_state->server_fd = -1;
  }

  if (plugin->rpc_state->accept_thread.joinable()) {
    plugin->rpc_state->accept_thread.join();
  }

  std::vector<std::shared_ptr<LinuxRpcConnection>> connections;
  {
    std::lock_guard<std::mutex> lock(plugin->rpc_state->mutex);
    for (const auto& entry : plugin->rpc_state->connections) {
      connections.push_back(entry.second);
    }
    plugin->rpc_state->connections.clear();
  }

  for (const auto& connection : connections) {
    shutdown(connection->fd, SHUT_RDWR);
    close(connection->fd);
  }

  if (!plugin->rpc_state->socket_path.empty()) {
    unlink(plugin->rpc_state->socket_path.c_str());
    plugin->rpc_state->socket_path.clear();
  }
}

bool send_rpc_packet(IslandDesktopPresencePlugin* plugin,
                     const std::string& connection_id,
                     int32_t packet_type,
                     const std::string& data_json,
                     std::string* error_message) {
  std::shared_ptr<LinuxRpcConnection> connection;
  {
    std::lock_guard<std::mutex> lock(plugin->rpc_state->mutex);
    const auto it = plugin->rpc_state->connections.find(connection_id);
    if (it == plugin->rpc_state->connections.end()) {
      *error_message = "Unknown RPC connection.";
      return false;
    }
    connection = it->second;
  }

  const auto packet = encode_rpc_packet(packet_type, data_json);
  if (send(connection->fd, packet.data(), packet.size(), 0) < 0) {
    *error_message = "Failed to write RPC packet.";
    return false;
  }

  if (packet_type == 2) {
    shutdown(connection->fd, SHUT_RDWR);
    close(connection->fd);
  }

  return true;
}

bool close_rpc_connection(IslandDesktopPresencePlugin* plugin,
                          const std::string& connection_id,
                          std::string* error_message) {
  std::shared_ptr<LinuxRpcConnection> connection;
  {
    std::lock_guard<std::mutex> lock(plugin->rpc_state->mutex);
    const auto it = plugin->rpc_state->connections.find(connection_id);
    if (it == plugin->rpc_state->connections.end()) {
      *error_message = "Unknown RPC connection.";
      return false;
    }
    connection = it->second;
  }

  shutdown(connection->fd, SHUT_RDWR);
  close(connection->fd);
  return true;
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

FlMethodErrorResponse* rpc_event_listen_cb(FlEventChannel* channel,
                                           FlValue* args,
                                           gpointer user_data) {
  auto* self = ISLAND_DESKTOP_PRESENCE_PLUGIN(user_data);
  self->rpc_is_listening = TRUE;

  for (guint i = 0; i < self->pending_rpc_events->len; ++i) {
    auto* event = static_cast<FlValue*>(
        g_ptr_array_index(self->pending_rpc_events, i));
    g_autoptr(GError) error = nullptr;
    fl_event_channel_send(self->rpc_event_channel, event, nullptr, &error);
  }
  g_ptr_array_set_size(self->pending_rpc_events, 0);
  return nullptr;
}

FlMethodErrorResponse* rpc_event_cancel_cb(FlEventChannel* channel,
                                           FlValue* args,
                                           gpointer user_data) {
  auto* self = ISLAND_DESKTOP_PRESENCE_PLUGIN(user_data);
  self->rpc_is_listening = FALSE;
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
  } else if (strcmp(method, "startRpcTransport") == 0) {
    std::string error_message;
    if (!start_rpc_transport(self, &error_message)) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "rpc_transport_unavailable", error_message.c_str(), nullptr));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    }
  } else if (strcmp(method, "stopRpcTransport") == 0) {
    stop_rpc_transport(self);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "sendRpcPacket") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "invalid_arguments", "Expected sendRpcPacket arguments.", nullptr));
    } else {
      FlValue* connection_value =
          fl_value_lookup_string(args, "connectionId");
      FlValue* packet_type_value =
          fl_value_lookup_string(args, "packetType");
      FlValue* data_json_value = fl_value_lookup_string(args, "dataJson");
      if (connection_value == nullptr || packet_type_value == nullptr ||
          data_json_value == nullptr ||
          fl_value_get_type(connection_value) != FL_VALUE_TYPE_STRING ||
          fl_value_get_type(packet_type_value) != FL_VALUE_TYPE_INT ||
          fl_value_get_type(data_json_value) != FL_VALUE_TYPE_STRING) {
        response = FL_METHOD_RESPONSE(fl_method_error_response_new(
            "invalid_arguments",
            "sendRpcPacket requires connectionId, packetType and dataJson.",
            nullptr));
      } else {
        std::string error_message;
        if (!send_rpc_packet(
                self,
                fl_value_get_string(connection_value),
                static_cast<int32_t>(fl_value_get_int(packet_type_value)),
                fl_value_get_string(data_json_value),
                &error_message)) {
          response = FL_METHOD_RESPONSE(fl_method_error_response_new(
              "rpc_send_failed", error_message.c_str(), nullptr));
        } else {
          response =
              FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
        }
      }
    }
  } else if (strcmp(method, "closeRpcConnection") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "invalid_arguments",
          "Expected closeRpcConnection arguments.", nullptr));
    } else {
      FlValue* connection_value =
          fl_value_lookup_string(args, "connectionId");
      if (connection_value == nullptr ||
          fl_value_get_type(connection_value) != FL_VALUE_TYPE_STRING) {
        response = FL_METHOD_RESPONSE(fl_method_error_response_new(
            "invalid_arguments",
            "closeRpcConnection requires a string connectionId.", nullptr));
      } else {
        std::string error_message;
        if (!close_rpc_connection(self, fl_value_get_string(connection_value),
                                  &error_message)) {
          response = FL_METHOD_RESPONSE(fl_method_error_response_new(
              "rpc_close_failed", error_message.c_str(), nullptr));
        } else {
          response =
              FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
        }
      }
    }
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void island_desktop_presence_plugin_dispose(GObject* object) {
  auto* self = ISLAND_DESKTOP_PRESENCE_PLUGIN(object);
  stop_rpc_transport(self);
  stop_monitoring(self, TRUE);
  g_clear_pointer(&self->pending_event, fl_value_unref);
  g_clear_object(&self->event_channel);
  g_clear_object(&self->rpc_event_channel);
  if (self->pending_rpc_events != nullptr) {
    g_ptr_array_unref(self->pending_rpc_events);
    self->pending_rpc_events = nullptr;
  }
  if (self->display != nullptr) {
    XCloseDisplay(self->display);
    self->display = nullptr;
  }
  delete self->rpc_state;
  self->rpc_state = nullptr;

  G_OBJECT_CLASS(island_desktop_presence_plugin_parent_class)->dispose(object);
}

static void island_desktop_presence_plugin_class_init(
    IslandDesktopPresencePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = island_desktop_presence_plugin_dispose;
}

static void island_desktop_presence_plugin_init(
    IslandDesktopPresencePlugin* self) {
  self->idle_threshold_milliseconds = 300000;
  self->pending_rpc_events =
      g_ptr_array_new_with_free_func(reinterpret_cast<GDestroyNotify>(
          fl_value_unref));
  self->rpc_state = new LinuxRpcState();
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

  plugin->rpc_event_channel = fl_event_channel_new(
      fl_plugin_registrar_get_messenger(registrar), kRpcEventChannelName,
      FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(plugin->rpc_event_channel,
                                       rpc_event_listen_cb,
                                       rpc_event_cancel_cb, g_object_ref(plugin),
                                       g_object_unref);

  g_object_unref(plugin);
}
