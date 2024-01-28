import 'package:logger/logger.dart';
import 'package:package_flutter/domain/socket/socket_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'socket_connection_provider.g.dart';

// TODO(P5ina): Add socket connection widget with lifecycle events
@Riverpod(keepAlive: true)
class SocketConnection extends _$SocketConnection {
  Future<void> connect() async {
    Logger().d('Connecting socket');
    return ref.read(socketRepositoryProvider).connect();
  }

  @override
  FutureOr<void> build() {
    return connect();
  }

  Future<void> disconnect() async {
    Logger().d('Disconnecting socket');
    return ref.read(socketRepositoryProvider).disconnect();
  }
}
