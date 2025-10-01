import 'package:flutter/widgets.dart';

const kWideScreenWidth = 768.0;
const kWiderScreenWidth = 1024.0;
const kWidescreenWidth = 1280.0;

bool isWideScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWideScreenWidth;
}

bool isWiderScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWiderScreenWidth;
}

bool isWidestScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWidescreenWidth;
}
