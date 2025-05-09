part of 'map_bloc.dart';

@freezed
sealed class MapState with _$MapState {
  const factory MapState.idle() = MapStateIdle;
  const factory MapState.moveToPlayer() = MapStateMoveToPlayer;
}
