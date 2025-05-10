import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_event.dart';
part 'map_state.dart';
part 'map_bloc.freezed.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(const MapState.idle()) {
    on<MapEvent>((event, emit) {
      switch (event) {
        case MapEventMovedToPlayer():
          emit(const MapState.moveToPlayer());
          emit(const MapState.idle());
      }
    });
  }
}
