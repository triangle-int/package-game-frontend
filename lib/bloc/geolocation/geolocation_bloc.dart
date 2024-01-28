import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/geolocation/geolocation_failure.dart';
import 'package:package_flutter/domain/geolocation/geolocation_repository.dart';
import 'package:package_flutter/domain/user/user_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'geolocation_event.dart';
part 'geolocation_state.dart';
part 'geolocation_bloc.freezed.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {
  final GeolocationRepository _geo;
  final UserRepository _userRepository;

  StreamSubscription? _geolocationStream;
  Position? _lastSendedLocation;

  GeolocationBloc(this._geo, this._userRepository)
      : super(const GeolocationState.initial()) {
    on<GeolocationEvent>((event, emit) async {
      await event.map(
        listenGeolocationRequested: (e) async {
          emit(const GeolocationState.loadInProgress());
          final failureOrUnit = await _geo.checkRequirements();

          failureOrUnit.fold(
            (f) => emit(GeolocationState.loadFailure(f)),
            (u) {
              _geolocationStream?.cancel();
              _geolocationStream = _geo
                  .geolocationStream()
                  .sampleTime(const Duration(milliseconds: 500))
                  .listen(
                    (positionOrFailure) => add(
                      GeolocationEvent.geolocationReceived(positionOrFailure),
                    ),
                  );
            },
          );
        },
        geolocationReceived: (e) {
          emit(
            e.positionOrFailure.fold(
              (f) => GeolocationState.loadFailure(f),
              (pos) {
                if (_lastSendedLocation == null ||
                    Geolocator.distanceBetween(
                          _lastSendedLocation!.latitude,
                          _lastSendedLocation!.longitude,
                          pos.latitude,
                          pos.longitude,
                        ) >
                        10) {
                  Logger().d('Distance is greater than 10');
                  _userRepository
                      .setLocation(LatLng(pos.latitude, pos.longitude));
                  _lastSendedLocation = pos;
                }
                return GeolocationState.loadSuccess(pos);
              },
            ),
          );
        },
        openAppSettings: (e) async {
          emit(const GeolocationState.loadInProgress());
          await _geo.openAppSettings();
          add(const GeolocationEvent.listenGeolocationRequested());
        },
        openLocationSettings: (e) async {
          emit(const GeolocationState.loadInProgress());
          await _geo.openLocationSettings();
          add(const GeolocationEvent.listenGeolocationRequested());
        },
        requestPermission: (e) async {
          emit(const GeolocationState.loadInProgress());
          await _geo.requestPermission();
          add(const GeolocationEvent.listenGeolocationRequested());
        },
      );
    });
  }

  @override
  Future<void> close() {
    _geolocationStream?.cancel();
    return super.close();
  }
}
