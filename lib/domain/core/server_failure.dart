import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

part 'server_failure.freezed.dart';

@freezed
sealed class ServerFailure with _$ServerFailure {
  const ServerFailure._();

  const factory ServerFailure.unknown(String message) = ServerFailureUnknown;
  const factory ServerFailure.playerNotFound() = ServerFailurePlayerNotFound;
  const factory ServerFailure.buildingNotFound() =
      ServerFailureBuildingNotFound;
  const factory ServerFailure.marketNotFound() = ServerFailureMarketNotFound;
  const factory ServerFailure.tooManyFactories() =
      ServerFailureTooManyFactories;
  const factory ServerFailure.zoneIsBusy() = ServerFailureZoneIsBusy;
  const factory ServerFailure.storageAlreadyExists() =
      ServerFailureStorageAlreadyExists;
  const factory ServerFailure.notEnoughCurrency() =
      ServerFailureNotEnoughCurrency;
  const factory ServerFailure.notEnoughGems() = ServerFailureNotEnoughGems;
  const factory ServerFailure.factoryAlreadyToggled() =
      ServerFailureFactoryAlreadyToggled;
  const factory ServerFailure.notEnoughResources() =
      ServerFailureNotEnoughResources;
  const factory ServerFailure.connectionTimedOut() =
      ServerFailureConnectionTimedOut;
  const factory ServerFailure.connectionRefused() =
      ServerFailureConnectionRefused;
  const factory ServerFailure.serverIsDown() = ServerFailureServerIsDown;
  const factory ServerFailure.banned(String reason) = ServerFailureBanned;

  factory ServerFailure.fromError(DioException error) {
    Logger().w('DioError: $error, Message: ${error.response?.data}');
    if (error.response != null) {
      if (error.response?.statusCode == 502) {
        return const ServerFailure.serverIsDown();
      }
      final message = (error.response!.data as Map<String, dynamic>)['message'];
      if (error.response?.statusCode == 403) {
        if (message == 'tooManyFactories') {
          return const ServerFailure.tooManyFactories();
        }
        if (message == 'zoneIsBusy' || message == 'cellTaken') {
          return const ServerFailure.zoneIsBusy();
        }
        if (message == 'marketNotFound') {
          return const ServerFailure.marketNotFound();
        }
        if (message == 'storageAlreadyExcists') {
          return const ServerFailure.storageAlreadyExists();
        }
        if (message == 'notEnoughCurrency' || message == 'notEnoughMoney') {
          return const ServerFailure.notEnoughCurrency();
        }
        if (message == 'notEnoughResources') {
          return const ServerFailure.notEnoughResources();
        }
        if (message == 'notEnoughGems') {
          return const ServerFailure.notEnoughGems();
        }
        if (message == 'banned') {
          final banObject =
              (error.response!.data as Map<String, dynamic>)['ban'];
          Logger().d('Ban object: $banObject');
          return ServerFailure.banned(
            (banObject as Map<String, dynamic>)['reason'] as String,
          );
        }
      }
      if (error.response?.statusCode == 404) {
        if (message == 'userNotFound') {
          return const ServerFailure.playerNotFound();
        }
      }
      return ServerFailure.unknown(message.toString());
    }
    if (error.type == DioExceptionType.connectionTimeout) {
      return const ServerFailure.connectionTimedOut();
    }
    if (error.type == DioExceptionType.connectionError) {
      return const ServerFailure.connectionRefused();
    }
    return ServerFailure.unknown(error.message ?? 'Unknown');
  }

  String getMessage() {
    return switch (this) {
      ServerFailureUnknown(:final message) => 'Unknown error: $message',
      ServerFailurePlayerNotFound() => 'Player not found',
      ServerFailureBuildingNotFound() => 'Building not found',
      ServerFailureMarketNotFound() => 'Market not found',
      ServerFailureTooManyFactories() => 'Too many factories',
      ServerFailureZoneIsBusy() => 'Zone is busy',
      ServerFailureStorageAlreadyExists() => 'Storage already exists',
      ServerFailureNotEnoughCurrency() => 'Not enough currency',
      ServerFailureFactoryAlreadyToggled() => 'Factory already toggled',
      ServerFailureNotEnoughResources() => 'Not enough resources',
      ServerFailureConnectionTimedOut() => 'Connection timed out',
      ServerFailureConnectionRefused() => 'Connection refused',
      ServerFailureBanned(:final reason) =>
        'You have been banned, reason: $reason',
      ServerFailureServerIsDown() => 'Server is down',
      ServerFailureNotEnoughGems() => 'Not enough gems',
    };
  }
}
