import 'package:flutter_map/flutter_map.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_bounds_provider.g.dart';

@riverpod
class MapBounds extends _$MapBounds {
  @override
  LatLngBounds build() {
    return LatLngBounds();
  }

  void setBounds(LatLngBounds bounds) {
    state = bounds;
  }
}
