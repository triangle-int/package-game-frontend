import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/auth/auth_provider.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/domain/user/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'user_provider.g.dart';

@riverpod
Stream<User> user(UserRef ref) {
  if (!ref.watch(authProvider).hasValue) {
    return const Stream.empty();
  }

  return ref.watch(userRepositoryProvider).getMe().doOnDone(() {
    Logger().d('User Stream Done!');
  });
}
