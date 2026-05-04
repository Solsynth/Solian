import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/compose.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ComposeRequest {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;
  final Completer<bool?> completer;

  ComposeRequest({
    this.originalPost,
    this.initialState,
    required this.completer,
  });
}

class ComposeNotifier extends Notifier<ComposeRequest?> {
  @override
  ComposeRequest? build() {
    return null;
  }

  void setRequest(ComposeRequest? request) {
    state = request;
  }
}

final composeRequestProvider =
    NotifierProvider<ComposeNotifier, ComposeRequest?>(() {
      return ComposeNotifier();
    });

Future<bool?> showCompose(
  BuildContext context,
  WidgetRef ref, {
  SnPost? originalPost,
  PostComposeInitialState? initialState,
}) {
  final completer = Completer<bool?>();

  ref
      .read(composeRequestProvider.notifier)
      .setRequest(
        ComposeRequest(
          originalPost: originalPost,
          initialState: initialState,
          completer: completer,
        ),
      );

  return completer.future;
}
