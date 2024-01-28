import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/inventory/inventory.dart';
import 'package:package_flutter/domain/inventory/inventory_failure.dart';
import 'package:package_flutter/domain/socket/socket_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_repository.g.dart';

@riverpod
InventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  return InventoryRepository(
    ref.watch(socketRepositoryProvider),
    ref.watch(dioProvider),
  );
}

class InventoryRepository {
  final SocketRepository _socketRepository;
  final Dio _dio;

  InventoryRepository(this._socketRepository, this._dio);

  Stream<Either<InventoryFailure, Inventory>> getInventory() async* {
    try {
      Logger().d('Get Inventory: Waiting for response');
      final response = await _dio.get('/inventory/fetch');
      Logger().d('Get Inventory: Parsing response\n'
          'Response: ${response.data}');
      final inventory =
          Inventory.fromJson(response.data as Map<String, dynamic>);
      Logger().d('Get Inventory: Emitting response');
      yield right(inventory);
    } on DioException catch (e) {
      yield left(InventoryFailure.serverFailure(e.message!));
    } finally {
      yield* _socketRepository.getInventoryUpdates().map((i) => right(i));
    }
  }
}
