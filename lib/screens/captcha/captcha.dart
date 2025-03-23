import 'package:flutter/foundation.dart' show kIsWeb;

export 'captcha_native.dart' if (kIsWeb) 'captcha_web.dart';
