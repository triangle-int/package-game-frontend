import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/core/ref_debounce_extension.dart';
import 'package:package_flutter/bloc/map/map_bounds_provider.dart';
import 'package:package_flutter/domain/user/user_on_map.dart';
import 'package:package_flutter/domain/user/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_in_bounds_provider.g.dart';

@riverpod
Stream<List<UserOnMap>> usersInBounds(Ref ref) {
  final bounds = ref.watch(mapBoundsProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  ref.debounce(const Duration(milliseconds: 200));

  return Stream.periodic(const Duration(milliseconds: 500), (_) {
    return userRepository.getUsersInBounds(
      minCoords: bounds.southWest,
      maxCoords: bounds.northEast,
    );
  }).asyncMap((event) => event);
}
