/// Cross-platform SVG helper.
///
/// On native platforms, uses dart:io File for cached SVGs.
/// On web, uses SvgPicture.network directly.
export 'svg_helper_native.dart'
    if (dart.library.js_interop) 'svg_helper_web.dart';
