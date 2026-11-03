import 'package:flutter_test/flutter_test.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/presentation/map/truck_path.dart';

void main() {
  final start = DateTime.utc(2026, 1, 1);
  final end = start.add(const Duration(minutes: 10));

  test('decodes the server precision', () {
    final encoded = encodePolyline([
      [55.755826, 37.6173],
      [55.755926, 37.6183],
    ], accuracyExponent: 6);
    final points = decodeTruckPath(encoded);
    expect(points.first.latitude, closeTo(55.755826, 0.000001));
    expect(points.last.longitude, closeTo(37.6183, 0.000001));
  });

  test('handles unavailable and stationary routes', () {
    expect(truckPosition([], start, end, start), isNull);
    const point = LatLng(55, 37);
    expect(truckPosition([point], start, end, start), point);
    expect(truckPosition([point, point], start, end, start), point);
  });

  test('clamps position and tolerates zero duration and repeated points', () {
    const a = LatLng(0, 0);
    const b = LatLng(0, 1);
    const c = LatLng(0, 2);
    final points = [a, a, b, c, c];
    expect(
        truckPosition(
            points, start, end, start.subtract(const Duration(seconds: 1))),
        a);
    final middle = truckPosition(
        points, start, end, start.add(const Duration(minutes: 5)))!;
    expect(middle.longitude, closeTo(1, 0.00001));
    expect(
        truckPosition(points, start, end, end.add(const Duration(seconds: 1))),
        c);
    expect(truckPosition(points, start, start, start), c);
  });
}
