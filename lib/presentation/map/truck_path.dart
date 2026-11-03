import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/data/latlng/lat_lng_extension.dart';

/// Decodes the six-decimal precision used by the server for all truck paths.
List<LatLng> decodeTruckPath(String encoded) {
  try {
    return decodePolyline(encoded, accuracyExponent: 6)
        .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
        .toList();
  } catch (_) {
    return const [];
  }
}

/// Returns null for an unavailable path and handles stationary or expired trips.
LatLng? truckPosition(
  List<LatLng> points,
  DateTime start,
  DateTime end,
  DateTime now,
) {
  if (points.isEmpty) return null;
  if (points.length == 1) return points.first;
  final duration = end.difference(start).inMilliseconds;
  final progress = duration <= 0
      ? 1.0
      : (now.difference(start).inMilliseconds / duration).clamp(0.0, 1.0);
  final distances = <double>[];
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final distance = points[i].calculateDistance(points[i + 1]).toDouble();
    distances.add(distance);
    total += distance;
  }
  if (total == 0) return points.last;
  final target = total * progress;
  var covered = 0.0;
  for (var i = 0; i < distances.length; i++) {
    final distance = distances[i];
    if (distance > 0 &&
        (target <= covered + distance || i == distances.length - 1)) {
      final fraction = ((target - covered) / distance).clamp(0.0, 1.0);
      return LatLng(
        points[i].latitude +
            (points[i + 1].latitude - points[i].latitude) * fraction,
        points[i].longitude +
            (points[i + 1].longitude - points[i].longitude) * fraction,
      );
    }
    covered += distance;
  }
  return points.last;
}
