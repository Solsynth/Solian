# Changelog

-----------------------------------------------

[0.4.1] - 2025.02.03

* [Fix] Updates firebase messaging and android gradle

[0.4.0] - 2023.08.24

* [fix] Extracting UI responsibility, named parameters, android dismissal fix (#189).
* [fix] make the Object nullable (#182)
* [chore] Updated to the latest flutter and firebase messaging (#185)
* [feat] Improve Android broadcasts and iOS delegate (#159)

[0.3.3] - 2023.01.25

* [fix] Remove as `type` to allow null assignment.

[0.3.2] - 2021.09.27

* [feat] Add backgroundMode for setup.
* [fix] Duplicated call onAnswer. New open method. (#111)
* [fix] Cannot receive answer call on Android 11 (#98)

[0.3.1] - 2021.07.27

* Add foregroundService for Android 11.

[0.3.0] - 2021.06.12

* null safety
* Add toolkit for testing.
* Fixed receiving Voip push in background mode for iOS 13+.
* Fix crash when iOS push uses the wrong push format (alert).

[0.2.4] - 2021.01.08

* Fix crash when appName is not set.
* hasDefaultPhoneAccount give feedback about the user choice.

[0.2.3] - 2021.01.08

* Fix backToForeground method.

[0.2.2] - 2020.12.27

* Update json format for push payload.

[0.2.1] - 2020.12.23

* Fix: Missing null check.
* Fix: change parameter handle to number.

[0.2.0] - 2020.11.11

* Change FlutterCallKeep as a singleton.
* Add CallKeepPushKitToken event for iOS.
* Add firebase_messaging to example.
* Support waking CallKeep from PushKit when the app is closed.

[0.1.1] - 2020.09.17

* Fix compile error for iOS.

[0.1.0] - 2020.09.15

* Initial release.
* Support iOS 10+ and Android 6.0+.
