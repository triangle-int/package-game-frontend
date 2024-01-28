import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/geolocation/geolocation_failure.dart';
import 'package:rxdart/rxdart.dart';

final geolocationRepositoryProvider =
    Provider((ref) => GeolocationRepository());

class GeolocationRepository {
  GeolocationRepository();

  Future<Either<GeolocationFailure, Unit>> checkRequirements() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return left(const GeolocationFailure.permissionDenied());
    }
    if (permission == LocationPermission.deniedForever) {
      return left(const GeolocationFailure.permissionDeniedForever());
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return left(const GeolocationFailure.serviceDisabled());
    }

    final accuracy = await Geolocator.getLocationAccuracy();
    if (accuracy == LocationAccuracyStatus.reduced) {
      return left(const GeolocationFailure.reducedAccuracy());
    }

    return right(unit);
  }

  Stream<Either<GeolocationFailure, Position>> geolocationStream() {
    return Geolocator.getPositionStream()
        .map((p) => right<GeolocationFailure, Position>(p))
        .onErrorReturnWith((error, stackTrace) {
      if (error is LocationServiceDisabledException) {
        return left(const GeolocationFailure.serviceDisabled());
      }
      if (error is TimeoutException) {
        return left(const GeolocationFailure.noSignal());
      }
      return left(const GeolocationFailure.unknown());
    });
  }

  Future<void> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<void> requestPermission() {
    return Geolocator.requestPermission();
  }
}
