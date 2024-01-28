part of 'connection_bloc.dart';

@freezed
class ConnectionEvent with _$ConnectionEvent {
  const factory ConnectionEvent.connectionRequested() = _ConnectionRequested;
  const factory ConnectionEvent.connectionLost() = _ConnectionLost;
}
