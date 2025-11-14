import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';
import 'package:package_flutter/domain/ban/ban.dart';
import 'package:package_flutter/domain/core/env/env.dart';
import 'package:package_flutter/domain/inventory/inventory.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'socket_repository.g.dart';

@riverpod
SocketRepository socketRepository(Ref ref) {
  return SocketRepository(
    ref.watch(authRepositoryProvider),
  );
}

class SocketRepository {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messagesController =
      StreamController<Map<String, dynamic>>.broadcast();

  final AuthRepository authRepository;

  SocketRepository(this.authRepository);

  Future<void> connect() async {
    if (_channel != null) {
      Logger().d('Socket already connected');
      return;
    }

    try {
      final token = await authRepository.getToken();
      final serverUrl = Env.getServerUrl();

      // Заменяем http на ws
      String wsUrl = serverUrl.replaceFirst('http', 'ws');
      wsUrl = wsUrl.replaceFirst('3001', '3002');
      Logger().d('Connecting to the $wsUrl');

      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl?token=$token'),
      );
      await _channel!.ready;

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String) as Map<String, dynamic>;
            Logger().d('Received message: $data');

            if (data['type'] == 'connected') {
              Logger().d('Socket connected as: ${data['uid']}');
              return;
            }

            _messagesController.add(data);
          } catch (e) {
            Logger().e('Error parsing message: $e');
          }
        },
        onError: (error) {
          Logger().e('WebSocket error: $error');
          _reconnect();
        },
        onDone: () {
          Logger().w('WebSocket closed');
          _reconnect();
        },
      );

      Logger().d('Socket connected');
    } catch (e) {
      Logger().e('Connection error: $e');
    }
  }

  Future<void> _reconnect() async {
    await disconnect();
    await Future.delayed(const Duration(seconds: 3));
    await connect();
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }

  Stream<User> getUserUpdates() async* {
    yield* _messagesController.stream
        .where((data) => data['channel'] == 'update')
        .map((data) {
      Logger().d('User parsed: ${data['data']}');
      return User.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  Stream<Inventory> getInventoryUpdates() async* {
    yield* _messagesController.stream
        .where((data) => data['channel'] == 'update')
        .map((data) {
      final inventory =
          Inventory.fromJson(data['data'] as Map<String, dynamic>);
      Logger().d('Inventory parsed: $inventory');
      return inventory;
    });
  }

  Stream<Ban?> getBanUpdates() async* {
    yield* _messagesController.stream
        .where((data) => data['channel'] == 'banUpdate')
        .map((data) {
      Logger().d('Ban received: ${data['data']}');
      if (data['data'] == null) return null;
      return Ban.fromJson(data['data'] as Map<String, dynamic>);
    });
  }

  Stream<Map<String, dynamic>> getTruckCreatedUpdates() async* {
    yield* _messagesController.stream
        .where((data) => data['channel'] == 'truckCreated')
        .map((data) {
      Logger().d('Truck created: ${data['data']}');
      return data['data'] as Map<String, dynamic>;
    });
  }

  Stream<Map<String, dynamic>> getTruckArrivedUpdates() async* {
    yield* _messagesController.stream
        .where((data) => data['channel'] == 'truckArrived')
        .map((data) {
      Logger().d('Truck arrived: ${data['data']}');
      return data['data'] as Map<String, dynamic>;
    });
  }
}
