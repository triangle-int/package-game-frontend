import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  final repository = SocketRepository(
    ref.watch(authRepositoryProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
}

class SocketRepository {
  WebSocketChannel? _channel;
  StreamSubscription? _authSubscription;
  Timer? _retryTimer;
  bool _wanted = false;
  bool _connecting = false;
  bool _connectAgain = false;
  int _generation = 0;
  final StreamController<Map<String, dynamic>> _messagesController =
      StreamController<Map<String, dynamic>>.broadcast();

  final AuthRepository authRepository;

  SocketRepository(this.authRepository) {
    _authSubscription = authRepository.authStateChanges().listen((state) {
      state.fold((_) => _close(), (_) {
        if (_wanted) connect();
      });
    });
  }

  Future<void> connect() async {
    _wanted = true;
    if (_channel != null) return;
    if (_connecting) {
      _connectAgain = true;
      return;
    }
    _retryTimer?.cancel();
    _connecting = true;
    final generation = _generation;

    try {
      final token = await authRepository.getToken();
      if (!_wanted || generation != _generation || token == null) return;
      final serverUrl = Env.getServerUrl();

      // Заменяем http на ws
      String wsUrl = serverUrl.replaceFirst('http', 'ws');
      if (kDebugMode && Uri.parse(wsUrl).port == 3005) {
        final uri = Uri.parse(wsUrl);
        wsUrl = uri.replace(port: 3006).toString();
      } else {
        wsUrl = wsUrl.replaceFirst('3001', '3002');
      }
      Logger().d('Connecting to the $wsUrl');

      final uri = Uri.parse(wsUrl).replace(queryParameters: {'token': token});
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      await channel.ready;
      if (!_wanted || generation != _generation) {
        await channel.sink.close();
        return;
      }

      channel.stream.listen(
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
          _reconnect(channel);
        },
        onDone: () {
          Logger().w('WebSocket closed');
          _reconnect(channel);
        },
      );

      Logger().d('Socket connected');
    } catch (e) {
      Logger().e('Connection error: $e');
      _channel = null;
      if (_wanted && generation == _generation) _scheduleReconnect();
    } finally {
      _connecting = false;
      if (_connectAgain && _wanted) {
        _connectAgain = false;
        connect();
      }
    }
  }

  void _reconnect(WebSocketChannel channel) {
    if (!identical(_channel, channel)) return;
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_wanted || _retryTimer?.isActive == true) return;
    _retryTimer = Timer(const Duration(seconds: 3), connect);
  }

  void _close() {
    _generation++;
    _retryTimer?.cancel();
    final channel = _channel;
    _channel = null;
    channel?.sink.close();
  }

  Future<void> disconnect() async {
    _wanted = false;
    _connectAgain = false;
    _close();
  }

  void dispose() {
    _wanted = false;
    _connectAgain = false;
    _close();
    _authSubscription?.cancel();
    _messagesController.close();
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
