import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final mapBoundsProvider = StateProvider((ref) => LatLngBounds());
