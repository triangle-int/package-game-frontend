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
  Position? _currentLocation;
  bool _userAvailable = false;
  bool _sendingLocation = false;

  void setUserAvailable(bool available) {
    _userAvailable = available;
    if (!available) {
      _lastSendedLocation = null;
    } else {
      unawaited(_sendCurrentLocation());
    }
  }

  Future<void> _sendCurrentLocation() async {
    final position = _currentLocation;
    if (!_userAvailable || _sendingLocation || position == null) return;
    if (_lastSendedLocation != null &&
        Geolocator.distanceBetween(
              _lastSendedLocation!.latitude,
              _lastSendedLocation!.longitude,
              position.latitude,
              position.longitude,
            ) <=
            10) return;

    _sendingLocation = true;
    try {
      await _userRepository
          .setLocation(LatLng(position.latitude, position.longitude));
      if (_userAvailable) _lastSendedLocation = position;
    } catch (error, stackTrace) {
      Logger()
          .w('Could not update location', error: error, stackTrace: stackTrace);
    } finally {
      _sendingLocation = false;
    }
  }

  GeolocationBloc(this._geo, this._userRepository)
      : super(const GeolocationState.initial()) {
    on<GeolocationEvent>((event, emit) async {
      switch (event) {
        case ListenGeolocationRequested():
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
        case GeolocationReceived(:final positionOrFailure):
          emit(
            positionOrFailure.fold(
              (f) => GeolocationState.loadFailure(f),
              (pos) {
                _currentLocation = pos;
                unawaited(_sendCurrentLocation());
                return GeolocationState.loadSuccess(pos);
              },
            ),
          );
        case OpenAppSettings():
          emit(const GeolocationState.loadInProgress());
          await _geo.openAppSettings();
          add(const GeolocationEvent.listenGeolocationRequested());
        case OpenLocationSettings():
          emit(const GeolocationState.loadInProgress());
          await _geo.openLocationSettings();
          add(const GeolocationEvent.listenGeolocationRequested());
        case RequestPermission():
          emit(const GeolocationState.loadInProgress());
          await _geo.requestPermission();
          add(const GeolocationEvent.listenGeolocationRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _geolocationStream?.cancel();
    return super.close();
  }
}
