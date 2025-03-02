import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket.freezed.dart';
part 'websocket.g.dart';

@freezed
abstract class WebSocketPackage with _$WebSocketPackage {
  const factory WebSocketPackage({
    @JsonKey(name: 'w') @Default('unknown') String method,
    @JsonKey(name: 'e') String? endpoint,
    @JsonKey(name: 'm') String? message,
    @JsonKey(name: 'p') @Default({}) Map<String, dynamic>? payload,
  }) = _WebSocketPackage;

  factory WebSocketPackage.fromJson(Map<String, dynamic> json) =>
      _$WebSocketPackageFromJson(json);
}
