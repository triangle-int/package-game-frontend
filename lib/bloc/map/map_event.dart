part of 'map_bloc.dart';

@freezed
class MapEvent with _$MapEvent {
  const factory MapEvent.movedToPlayer() = _MovedToPlayer;
}
