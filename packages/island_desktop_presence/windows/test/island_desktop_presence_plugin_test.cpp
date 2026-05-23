#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <memory>
#include <string>
#include <variant>

#include "island_desktop_presence_plugin.h"

namespace island_desktop_presence {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResultFunctions;

}  // namespace

TEST(IslandDesktopPresencePlugin, GetIdleTime) {
  IslandDesktopPresencePlugin plugin;
  int64_t result_value = -1;
  plugin.HandleMethodCall(
      MethodCall("getIdleTime", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          [&result_value](const EncodableValue* result) {
            result_value = static_cast<int64_t>(std::get<int64_t>(*result));
          },
          nullptr, nullptr));

  EXPECT_GE(result_value, 0);
}

}  // namespace test
}  // namespace island_desktop_presence
