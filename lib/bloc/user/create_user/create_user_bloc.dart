import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/user/create_user_failure.dart';
import 'package:package_flutter/domain/user/user_repository.dart';

part 'create_user_event.dart';
part 'create_user_state.dart';
part 'create_user_bloc.freezed.dart';

class CreateUserBloc extends Bloc<CreateUserEvent, CreateUserState> {
  final UserRepository _repository;

  CreateUserBloc(this._repository) : super(CreateUserState.initial()) {
    on<CreateUserEvent>((event, emit) async {
      switch (event) {
        case CreateUserEventAvatarChanged(:final avatar):
          emit(state.copyWith(avatar: avatar, failureOrNull: null));
        case CreateUserEventNicknameChanged(:final nickname):
          emit(state.copyWith(nickname: nickname, failureOrNull: null));
        case CreateUserEventConfirmed():
          emit(
            state.copyWith(
              isSubmitting: true,
              failureOrNull: null,
            ),
          );

          final failureOrUnit = await _repository.createUser(
            nickname: state.nickname,
            avatar: state.avatar,
          );

          emit(
            state.copyWith(
              isSubmitting: false,
              failureOrNull: failureOrUnit.fold((f) => f, (_) => null),
            ),
          );
      }
    });
  }
}
