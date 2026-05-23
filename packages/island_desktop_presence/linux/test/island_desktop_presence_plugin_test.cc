#include <flutter_linux/flutter_linux.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "include/island_desktop_presence/island_desktop_presence_plugin.h"
#include "island_desktop_presence_plugin_private.h"

namespace island_desktop_presence {
namespace test {

TEST(IslandDesktopPresencePlugin, GetIdleTimeResponse) {
  g_autoptr(FlMethodResponse) response = get_idle_time_response(42000);
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  FlValue* result = fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response));
  ASSERT_EQ(fl_value_get_type(result), FL_VALUE_TYPE_INT);
  EXPECT_EQ(fl_value_get_int(result), 42000);
}

}  // namespace test
}  // namespace island_desktop_presence
