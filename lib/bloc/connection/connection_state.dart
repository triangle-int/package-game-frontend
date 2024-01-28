part of 'connection_bloc.dart';

@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState.hasConnection() = _HasConnection;
  const factory ConnectionState.connectionInProgress() = _ConnectionInProgress;
  const factory ConnectionState.noConnection() = _NoConnection;
}
