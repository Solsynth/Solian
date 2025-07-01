import 'package:freezed_annotation/freezed_annotation.dart';

part 'auto_completion.freezed.dart';
part 'auto_completion.g.dart';

@freezed
sealed class AutoCompletionResponse with _$AutoCompletionResponse {
  const factory AutoCompletionResponse.account({
    required String type,
    required List<AutoCompletionItem> items,
  }) = AutoCompletionAccountResponse;

  const factory AutoCompletionResponse.sticker({
    required String type,
    required List<AutoCompletionItem> items,
  }) = AutoCompletionStickerResponse;

  factory AutoCompletionResponse.fromJson(Map<String, dynamic> json) =>
      _$AutoCompletionResponseFromJson(json);
}

@freezed
sealed class AutoCompletionItem with _$AutoCompletionItem {
  const factory AutoCompletionItem({
    required String id,
    required String displayName,
    required String? secondaryText,
    required String type,
    required dynamic data,
  }) = _AutoCompletionItem;

  factory AutoCompletionItem.fromJson(Map<String, dynamic> json) =>
      _$AutoCompletionItemFromJson(json);
}
