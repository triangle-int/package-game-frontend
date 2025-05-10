import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_bounds_provider.g.dart';

@riverpod
class MapBounds extends _$MapBounds {
  @override
  LatLngBounds build() {
    return LatLngBounds(
      LatLng(0, 0),
      LatLng(0, 0),
    );
  }

  void setBounds(LatLngBounds bounds) {
    state = bounds;
  }
}
