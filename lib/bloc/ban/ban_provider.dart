import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/socket/socket_repository.dart';

final banProvider = StreamProvider(
  (ref) => ref.watch(socketRepositoryProvider).getBanUpdates(),
);
