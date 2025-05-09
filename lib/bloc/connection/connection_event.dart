part of 'connection_bloc.dart';

@freezed
class ConnectionEvent with _$ConnectionEvent {
  const factory ConnectionEvent.connectionRequested() = ConnectionRequested;
  const factory ConnectionEvent.connectionLost() = ConnectionLost;
}
