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
import 'package:socket_io_client/socket_io_client.dart' as io;

part 'socket_repository.g.dart';

@riverpod
SocketRepository socketRepository(Ref ref) {
  return SocketRepository(
    ref.watch(authRepositoryProvider),
  );
}

class SocketRepository {
  io.Socket? _socket;

  final AuthRepository authRepository;

  SocketRepository(this.authRepository);

  Future<void> connect() async {
    if (_socket == null) {
      final serverSocketUrl = Env.getServerUrl();

      _socket = io.io(
        serverSocketUrl,
        io.OptionBuilder()
            .setAuth({'token': await authRepository.getToken()})
            .setTransports(
              ['websocket'],
            )
            .disableAutoConnect()
            .build(),
      );

      _socket!.on('connect', (_) {
        Logger().d('Socket connected');
      });
      _socket!.on('connect_error', (e) {
        Logger().e('Connection socket error! $e');
      });
    }

    if (_socket!.connected) return;

    _socket!.connect();
  }

  Future<void> disconnect() async {
    if (_socket == null && _socket!.disconnected) return;

    _socket?.disconnect();
  }

  Stream<User> getUserUpdates() async* {
    if (_socket == null) {
      Logger().w('Socket is not connected');
      return;
    }

    final userStreamController = StreamController<User>();

    _socket!.on('update', (data) {
      final rawJson = jsonDecode(data as String);
      Logger().d('User parsed $rawJson');
      userStreamController.add(User.fromJson(rawJson as Map<String, dynamic>));
    });
    Logger().d('Updates listening');
    yield* userStreamController.stream;
  }

  Stream<Inventory> getInventoryUpdates() async* {
    if (_socket == null) {
      Logger().w('Socket is not connected');
      return;
    }

    final inventoryStreamController = StreamController<Inventory>();

    _socket!.on('update', (data) {
      final rawJson = jsonDecode(data as String);
      final inventory = Inventory.fromJson(rawJson as Map<String, dynamic>);
      inventoryStreamController.add(inventory);
      Logger().d('Inventory parsed: $inventory');
    });

    yield* inventoryStreamController.stream;
  }

  Stream<Ban?> getBanUpdates() async* {
    if (_socket == null) {
      Logger().w('Socket is not connected');
      return;
    }

    final banStreamController = StreamController<Ban?>();

    _socket!.on('banUpdate', (data) {
      Logger().d('Ban received, $data');
      final rawJson = jsonDecode(data as String);
      if (rawJson == null) {
        banStreamController.add(null);
        return;
      }
      final ban = Ban.fromJson(rawJson as Map<String, dynamic>);
      banStreamController.add(ban);
    });

    yield* banStreamController.stream;
  }
}
