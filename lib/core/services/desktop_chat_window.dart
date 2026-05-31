import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart';

enum DesktopWindowKind { primary, chatRoom }

class DesktopWindowLaunchDetails {
  const DesktopWindowLaunchDetails.primary()
    : kind = DesktopWindowKind.primary,
      roomId = null;

  const DesktopWindowLaunchDetails.chatRoom(this.roomId)
    : kind = DesktopWindowKind.chatRoom;

  final DesktopWindowKind kind;
  final String? roomId;

  bool get isPrimary => kind == DesktopWindowKind.primary;
}

const _desktopWindowTypeKey = 'type';
const _desktopWindowRoomIdKey = 'roomId';
const _desktopWindowTypeChatRoom = 'chat_room';
const _desktopWindowRpcChannelName = 'island.desktop_window.rpc';
const desktopWindowRefreshRoomMethod = 'chat.refresh_room';
const desktopWindowRefreshRoomsMethod = 'chat.refresh_rooms';
const desktopWindowGetCurrentUserMethod = 'app.get_current_user';
const desktopWindowCloseMethod = 'window.close';

final desktopWindowLaunchDetailsProvider = Provider<DesktopWindowLaunchDetails>(
  (ref) => const DesktopWindowLaunchDetails.primary(),
);

bool get supportsDesktopMultiWindow =>
    !kIsWeb &&
    (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

bool isPrimaryDesktopWindow(Ref ref) =>
    ref.read(desktopWindowLaunchDetailsProvider).isPrimary;

Future<DesktopWindowLaunchDetails> resolveDesktopWindowLaunchDetails() async {
  if (!supportsDesktopMultiWindow) {
    return const DesktopWindowLaunchDetails.primary();
  }

  try {
    final controller = await WindowController.fromCurrentEngine();
    return _parseDesktopWindowArguments(controller.arguments);
  } catch (error, stackTrace) {
    Logger.root.warning(
      '[DesktopMultiWindow] Failed to resolve launch details',
      error,
      stackTrace,
    );
    return const DesktopWindowLaunchDetails.primary();
  }
}

Future<void> openChatRoomInSeparateWindow(String roomId) async {
  if (!supportsDesktopMultiWindow) return;

  final existingControllers = await WindowController.getAll();
  for (final controller in existingControllers) {
    final details = _parseDesktopWindowArguments(controller.arguments);
    if (details.kind == DesktopWindowKind.chatRoom &&
        details.roomId == roomId) {
      await controller.show();
      return;
    }
  }

  final controller = await WindowController.create(
    WindowConfiguration(
      hiddenAtLaunch: true,
      arguments: jsonEncode({
        _desktopWindowTypeKey: _desktopWindowTypeChatRoom,
        _desktopWindowRoomIdKey: roomId,
      }),
    ),
  );
  await controller.show();
}

Future<void> registerPrimaryDesktopWindowRpcHandler(
  Future<dynamic> Function(MethodCall call) handler,
) async {
  if (!supportsDesktopMultiWindow) return;
  const channel = WindowMethodChannel(
    _desktopWindowRpcChannelName,
    mode: ChannelMode.unidirectional,
  );
  await channel.setMethodCallHandler(handler);
}

Future<T?> invokePrimaryDesktopWindowRpc<T>(
  String method, [
  dynamic arguments,
]) async {
  if (!supportsDesktopMultiWindow) return null;
  const channel = WindowMethodChannel(
    _desktopWindowRpcChannelName,
    mode: ChannelMode.unidirectional,
  );
  try {
    return await channel.invokeMethod<T>(method, arguments);
  } catch (error, stackTrace) {
    Logger.root.warning(
      '[DesktopMultiWindow] RPC failed for $method',
      error,
      stackTrace,
    );
    return null;
  }
}

Future<void> registerCurrentDesktopWindowHandler(
  Future<dynamic> Function(MethodCall call) handler,
) async {
  if (!supportsDesktopMultiWindow) return;
  final controller = await WindowController.fromCurrentEngine();
  await controller.setWindowMethodHandler(handler);
}

Future<void> broadcastToDesktopChatWindows(
  String method, [
  dynamic arguments,
]) async {
  if (!supportsDesktopMultiWindow) return;
  final controllers = await WindowController.getAll();
  for (final controller in controllers) {
    final details = _parseDesktopWindowArguments(controller.arguments);
    if (details.kind != DesktopWindowKind.chatRoom) continue;
    try {
      await controller.invokeMethod(method, arguments);
    } catch (error, stackTrace) {
      Logger.root.warning(
        '[DesktopMultiWindow] Failed to broadcast $method to ${controller.windowId}',
        error,
        stackTrace,
      );
    }
  }
}

Future<void> closeAllDesktopChatWindows() async {
  await broadcastToDesktopChatWindows(desktopWindowCloseMethod);
}

DesktopWindowLaunchDetails _parseDesktopWindowArguments(String arguments) {
  if (arguments.isEmpty) {
    return const DesktopWindowLaunchDetails.primary();
  }

  try {
    final payload = jsonDecode(arguments);
    if (payload is! Map) {
      return const DesktopWindowLaunchDetails.primary();
    }

    final type = payload[_desktopWindowTypeKey]?.toString();
    if (type == _desktopWindowTypeChatRoom) {
      final roomId = payload[_desktopWindowRoomIdKey]?.toString();
      if (roomId != null && roomId.isNotEmpty) {
        return DesktopWindowLaunchDetails.chatRoom(roomId);
      }
    }
  } catch (error, stackTrace) {
    Logger.root.warning(
      '[DesktopMultiWindow] Failed to parse window arguments: $arguments',
      error,
      stackTrace,
    );
  }

  return const DesktopWindowLaunchDetails.primary();
}
