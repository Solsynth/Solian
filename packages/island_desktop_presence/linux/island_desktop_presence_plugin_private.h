#include <flutter_linux/flutter_linux.h>

#include "include/island_desktop_presence/island_desktop_presence_plugin.h"

// This file exposes some plugin internals for unit testing. See
// https://github.com/flutter/flutter/issues/88724 for current limitations
// in the unit-testable API.

// Builds a successful getIdleTime response for unit tests.
FlMethodResponse* get_idle_time_response(gint64 idle_milliseconds);
