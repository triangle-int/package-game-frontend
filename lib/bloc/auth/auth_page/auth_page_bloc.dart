import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/auth/auth_failure.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';

part 'auth_page_event.dart';
part 'auth_page_state.dart';
part 'auth_page_bloc.freezed.dart';

class AuthPageBloc extends Bloc<AuthPageEvent, AuthPageState> {
  final AuthRepository _auth;

  AuthPageBloc(this._auth) : super(AuthPageState.initial()) {
    on<AuthPageEvent>((event, emit) async {
      await event.map(
        signedInWithGoogle: (e) async {
          emit(state.copyWith(isSubmitting: true, failureOrNull: null));
          final failureOrUnit = await _auth.signInWithGoogle();
          emit(
            state.copyWith(
              isSubmitting: false,
              failureOrNull: failureOrUnit.fold((l) => l, (r) => null),
            ),
          );
        },
        signedInWithApple: (e) async {
          emit(state.copyWith(isSubmitting: true, failureOrNull: null));
          final failureOrUnit = await _auth.signInWithApple();
          emit(
            state.copyWith(
              isSubmitting: false,
              failureOrNull: failureOrUnit.fold((l) => l, (r) => null),
            ),
          );
        },
      );
    });
  }
}
