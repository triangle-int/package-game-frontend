part of 'map_bloc.dart';

@freezed
sealed class MapEvent with _$MapEvent {
  const factory MapEvent.movedToPlayer() = MapEventMovedToPlayer;
}
