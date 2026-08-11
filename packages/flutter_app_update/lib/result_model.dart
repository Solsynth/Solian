/// createTime: 2024/11/1 on 11:24
/// desc:
///
/// @author azhon
class ResultModel {
  ResultType? type;
  int? max;
  int? progress;
  String? apk;
  String? exception;

  ResultModel({
    required this.type,
    this.max,
    this.progress,
    this.apk,
    this.exception,
  });

  ResultModel.fromJson(Map<String, dynamic> map) {
    type = ResultType.from(map['type']);
    max = map['max'];
    progress = map['progress'];
    apk = map['apk'];
    exception = map['exception'];
  }

  @override
  String toString() {
    return 'ResultModel{type: $type, max: $max, progress: $progress, apk: $apk, exception: $exception}';
  }
}

enum ResultType {
  ///start download
  start('start'),

  ///downloading, [ResultModel.max],[ResultModel.progress] has extra
  downloading('downloading'),

  ///downloaded, [ResultModel.apk] has extra
  done('done'),

  ///cancel download
  cancel('cancel'),

  ///download error, [ResultModel.exception] has extra
  error('error'),
  ;

  final String value;

  const ResultType(this.value);

  static from(String value) {
    switch (value) {
      case 'start':
        return ResultType.start;
      case 'downloading':
        return ResultType.downloading;
      case 'done':
        return ResultType.done;
      case 'cancel':
        return ResultType.cancel;
      case 'error':
        return ResultType.error;
    }
  }
}
