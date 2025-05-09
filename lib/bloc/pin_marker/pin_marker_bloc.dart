import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geohex/geohex.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/data/latlng/lat_lng_extension.dart';
import 'package:package_flutter/domain/config/config.dart';

part 'pin_marker_event.dart';
part 'pin_marker_state.dart';
part 'pin_marker_bloc.freezed.dart';

class PinMarkerBloc extends Bloc<PinMarkerEvent, PinMarkerState> {
  PinMarkerBloc() : super(PinMarkerState.initial()) {
    on<PinMarkerEvent>((event, emit) async {
      switch (event) {
        case PinMarkerEventPlaced(
            :final location,
            :final circleCenter,
            :final circleRadius,
            :final config
          ):
          final distance = location.calculateDistance(circleCenter);

          if (circleRadius < distance) {
            return;
          }

          emit(
            state.copyWith(
              location: location,
              cell: Zone.byLocation(
                location.latitude,
                location.longitude,
                config.buildingsCellLevel,
              ),
              isShown: true,
            ),
          );
        case PinMarkerEventHidden():
          emit(
            state.copyWith(
              isShown: false,
            ),
          );
      }
    });
  }
}
