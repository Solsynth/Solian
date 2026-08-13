import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_decoration.freezed.dart';

@freezed
sealed class ProfileDecoration with _$ProfileDecoration {
  const factory ProfileDecoration({
    required String text,
    required Color color,
    Color? textColor,
  }) = _ProfileDecoration;
}
