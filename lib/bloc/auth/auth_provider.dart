import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<User> auth(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges().map(
        (value) => value.fold(
          (f) => throw Exception(
            f.map(
              unauthenticated: (_) => 'Unauthenticated',
              canceled: (_) => 'Canceled by user',
              firebaseFailure: (_) => 'Firebase failure',
              unknown: (_) => 'Unknown error',
            ),
          ),
          (r) => r,
        ),
      );
}
