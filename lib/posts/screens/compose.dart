import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'compose.freezed.dart';
part 'compose.g.dart';

@freezed
sealed class PostComposeInitialState with _$PostComposeInitialState {
  const factory PostComposeInitialState({
    String? title,
    String? description,
    String? content,
    @Default([]) List<UniversalFile> attachments,
    int? visibility,
    SnPost? replyingTo,
    SnPost? forwardingTo,
  }) = _PostComposeInitialState;

  factory PostComposeInitialState.fromJson(Map<String, dynamic> json) =>
      _$PostComposeInitialStateFromJson(json);
}
