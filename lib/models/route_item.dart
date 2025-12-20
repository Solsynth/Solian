import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_item.freezed.dart';

@freezed
sealed class RouteItem with _$RouteItem {
  const factory RouteItem({
    required String name,
    required String path,
    required String description,
    required IconData icon,
  }) = _RouteItem;
}
