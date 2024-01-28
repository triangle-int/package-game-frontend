import 'package:package_flutter/domain/ban/ban.dart';
import 'package:package_flutter/domain/socket/socket_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ban_provider.g.dart';

@riverpod
Stream<Ban?> ban(BanRef ref) {
  return ref.watch(socketRepositoryProvider).getBanUpdates();
}
