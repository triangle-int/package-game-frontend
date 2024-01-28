import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/auth/auth_failure.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _auth;

  StreamSubscription? _authStatusStream;

  AuthBloc(this._auth) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) {
      event.map(
        listenAuthStatusRequested: (e) {
          emit(const AuthState.loadInProgress());
          _authStatusStream?.cancel();
          _authStatusStream = _auth.authStateChanges().listen(
                (userOrFailure) =>
                    add(AuthEvent.authStatusReceived(userOrFailure)),
              );
        },
        authStatusReceived: (e) {
          Logger().d(
            e.userOrFailure.fold(
              (l) => 'Auth failure',
              (r) => 'Auth success',
            ),
          );
          emit(
            e.userOrFailure.fold(
              (l) => AuthState.loadFailure(l),
              (r) => AuthState.loadSuccess(r),
            ),
          );
        },
        signedOut: (e) {
          _auth.signOut();
          emit(const AuthState.loadFailure(AuthFailure.unauthenticated()));
        },
      );
    });
  }

  @override
  Future<void> close() {
    _authStatusStream?.cancel();
    return super.close();
  }
}
