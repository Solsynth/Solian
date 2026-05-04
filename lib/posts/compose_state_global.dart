import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/responsive.dart';
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

Future<bool?> showComposeOverlay(
  BuildContext context, {
  SnPost? originalPost,
  PostComposeInitialState? initialState,
}) async {
  if (isWideScreen(context)) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => _ComposeOverlay(
        originalPost: originalPost,
        initialState: initialState,
      ),
    );
  } else {
    // On narrow screens, use full-screen bottom sheet
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 1.0,
        maxChildSize: 1.0,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: const Placeholder(), // TODO: Implement
        ),
      ),
    );
  }
}

class _ComposeOverlay extends StatelessWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;

  const _ComposeOverlay({this.originalPost, this.initialState});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800,
          minHeight: 400,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: const Placeholder(), // TODO: Implement
        ),
      ),
    );
  }
}
