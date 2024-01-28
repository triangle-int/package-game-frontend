import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/fm_market/my_trade.dart';
import 'package:package_flutter/domain/fm_market/trade_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fm_market_repository.g.dart';

@riverpod
FmMarketRepository fmMarketRepository(FmMarketRepositoryRef ref) {
  return FmMarketRepository(ref.watch(dioProvider));
}

class FmMarketRepository {
  final Dio _dio;

  FmMarketRepository(this._dio);

  Future<Either<ServerFailure, List<TradeItem>>> fetchTrades({
    required int page,
    required List<String> resources,
    required String nickname,
  }) async {
    try {
      final response = await _dio.post(
        '/trade/get-trades',
        data: {
          'page': page,
          'resources': resources,
          'nickname': nickname,
        },
      );

      return right(
        (response.data as List)
            .map((e) => TradeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> buyTrade({
    required int tradeId,
    required int resourcesCount,
  }) async {
    try {
      await _dio.post(
        '/trade/buy-trade',
        data: {
          'tradeId': tradeId,
          'resourcesCount': resourcesCount,
        },
      );

      return right(unit);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, List<MyTrade>>> myTrades() async {
    try {
      final response = await _dio.get('/trade/my-trades');

      Logger().d(response.data);

      return right(
        (response.data as List)
            .map((e) => MyTrade.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id)),
      );
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> setPrice({
    required int tradeId,
    required int price,
  }) async {
    try {
      await _dio.post(
        '/trade/set-price',
        data: {
          'tradeId': tradeId,
          'price': price,
        },
      );

      return right(unit);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }
}
