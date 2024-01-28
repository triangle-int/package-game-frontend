import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/connection/connection_repository.dart';

part 'connection_event.dart';
part 'connection_state.dart';
part 'connection_bloc.freezed.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final ConnectionRepository _repository;

  ConnectionBloc(this._repository)
      : super(const ConnectionState.hasConnection()) {
    on<ConnectionEvent>((event, emit) async {
      await event.map(
        connectionRequested: (_) async {
          emit(const ConnectionState.connectionInProgress());
          final failureOrUnit = await _repository.testConnection();
          failureOrUnit.fold(
            (failure) => emit(const ConnectionState.noConnection()),
            (_) => emit(const ConnectionState.hasConnection()),
          );
        },
        connectionLost: (_) async => emit(const ConnectionState.noConnection()),
      );
    });
  }
}
