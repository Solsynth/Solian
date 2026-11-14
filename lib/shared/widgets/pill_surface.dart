import 'package:island/core/theme.dart';

export 'package:island_ui_foundation/island_ui_foundation.dart'
    show PillSurface;

/// Side gutter of a pill: the capsule sits [SolSpace.md] in from each edge of
/// its container so the end caps clear it.
const double kPillSideGutter = SolSpace.md;

/// Inner height of a pill bar's capsule — the glass box itself, before the
/// status-bar inset and the top gutter are added on top.
const double kPillBarContentHeight = SolSpace.control + SolSpace.md;
