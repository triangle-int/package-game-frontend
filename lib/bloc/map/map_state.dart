part of 'map_bloc.dart';

@freezed
class MapState with _$MapState {
  const factory MapState.idle() = _Idle;
  const factory MapState.moveToPlayer() = _MoveToPlayer;
}
