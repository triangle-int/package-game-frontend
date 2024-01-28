import 'package:latlong2/latlong.dart';

extension LatLngExtension on LatLng {
  num calculateDistance(LatLng to) {
    final start = LatLng(latitude, longitude);
    final end = LatLng(to.latitude, to.longitude);
    const distance = Distance();
    return distance(start, end);
  }
}
