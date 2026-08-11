### [Chinese Doc](https://github.com/azhon/flutter_app_update/blob/main/README-CN.md)

### 一、Introduce
- Android update use [AppUpdate](https://github.com/azhon/AppUpdate) library
- Add to pubspec.yaml [pub versions](https://pub.dev/packages/flutter_app_update)
```yaml
dependencies:
  flutter_app_update: ^latest_version
```

- Create `UpdateModel` and set apk url

```dart
 UpdateModel model = UpdateModel(
   url,
   "flutterUpdate.apk",
   /// android res/mipmap icon name
   "ic_launcher",
   'https://itunes.apple.com/cn/app/xxxx',
 );
 AzhonAppUpdate.update(model).then((value) => debugPrint('$value'));
```
- Add listener

```dart
@override
void initState() {
  super.initState();
  AzhonAppUpdate.listener((ResultModel model) {
    debugPrint('$model');
  });
}
```

### 三、Screenshot

<img src="https://raw.githubusercontent.com/azhon/FlutterAppUpdate/main/example/img/en/img1.jpg" width="300">　<img src="https://raw.githubusercontent.com/azhon/FlutterAppUpdate/main/example/img/en/img2.jpg" width="300">
<img src="https://raw.githubusercontent.com/azhon/FlutterAppUpdate/main/example/img/en/img3.jpg" width="300">　<img src="https://raw.githubusercontent.com/azhon/FlutterAppUpdate/main/example/img/en/img4.jpg" width="300">
