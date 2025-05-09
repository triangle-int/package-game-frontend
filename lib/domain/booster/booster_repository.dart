import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/booster/booster.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'booster_repository.g.dart';

@riverpod
BoosterRepository boosterRepository(Ref ref) {
  return BoosterRepository(ref.watch(dioProvider));
}

class BoosterRepository {
  final Dio _dio;

  BoosterRepository(this._dio);

  Future<void> useBooster(String boosterType) async {
    await _dio.post(
      '/booster/activate-booster',
      data: {
        'boosterType': boosterType,
      },
    );
  }

  Future<List<Booster>> getActiveBoosters() async {
    final response = await _dio.get('/booster/get-boosters');
    return (response.data as List)
        .map((e) => Booster.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
