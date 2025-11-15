import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

import '../models/file.dart';
import '../widgets/content/cloud_files.dart';

/// Returns an appropriate icon widget for the given file based on its MIME type
Widget getFileIcon(
  SnCloudFile file, {
  required double size,
  bool tinyPreview = true,
}) {
  final itemType = file.mimeType?.split('/').firstOrNull;
  final mimeType = file.mimeType ?? '';
  final extension = file.name.split('.').lastOrNull?.toLowerCase() ?? '';

  // For images, show the actual image thumbnail
  if (itemType == 'image' && tinyPreview) {
    return CloudImageWidget(file: file);
  }

  // Return icon based on MIME type or file extension
  final icon = switch ((itemType, mimeType, extension)) {
    ('image', _, _) => Symbols.image,
    ('audio', _, _) => Symbols.audio_file,
    ('video', _, _) => Symbols.video_file,
    ('application', 'application/pdf', _) => Symbols.picture_as_pdf,
    ('application', 'application/zip', _) => Symbols.archive,
    ('application', 'application/x-rar-compressed', _) => Symbols.archive,
    (
      'application',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      _,
    ) ||
    ('application', 'application/msword', _) => Symbols.description,
    (
      'application',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      _,
    ) ||
    ('application', 'application/vnd.ms-excel', _) => Symbols.table_chart,
    (
      'application',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      _,
    ) ||
    ('application', 'application/vnd.ms-powerpoint', _) => Symbols.slideshow,
    ('text', _, _) => Symbols.article,
    ('application', _, 'js') ||
    ('application', _, 'dart') ||
    ('application', _, 'py') ||
    ('application', _, 'java') ||
    ('application', _, 'cpp') ||
    ('application', _, 'c') ||
    ('application', _, 'cs') => Symbols.code,
    ('application', _, 'json') ||
    ('application', _, 'xml') => Symbols.data_object,
    (_, _, 'md') => Symbols.article,
    (_, _, 'html') => Symbols.web,
    (_, _, 'css') => Symbols.css,
    _ => Symbols.description, // Default icon
  };

  return Icon(icon, size: size, fill: 1).center();
}
