### 一、使用说明
- Android这一侧的下载依赖[AppUpdate库](https://github.com/azhon/AppUpdate)
- 添加依赖 [pub versions](https://pub.dev/packages/flutter_app_update)
```yaml
dependencies:
  flutter_app_update: ^latest_version
```

- 创建`UpdateModel`设置下载地址

```dart
 UpdateModel model = UpdateModel(
   url,
   "flutterUpdate.apk",
   /// android res/mipmap 目录下的图片名称
   "ic_launcher",
   'https://itunes.apple.com/cn/app/抖音/id1142110895',
 );
 AzhonAppUpdate.update(model).then((value) => debugPrint('$value'));
```

- 监听下载过程

```dart
@override
void initState() {
  super.initState();
  AzhonAppUpdate.listener((ResultModel model) {
    debugPrint('$model');
  });
}
```

### 三、效果图

<img src="https://raw.githubusercontent.com/azhon/FlutterAppUpdate/main/example/img/img1.png" width="300">　<img src="https://raw.githubusercontent.com/azhon/FlutterAppUpdate/main/example/img/img2.png" width="300">
<img src="https://raw.githubusercontent.com/azhon/FlutterAppUpdate/main/example/img/img3.png" width="300">　<img src="https://raw.githubusercontent.com/azhon/FlutterAppUpdate/main/example/img/img4.png" width="300">
