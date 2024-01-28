import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

part 'server_failure.freezed.dart';

@freezed
class ServerFailure with _$ServerFailure {
  const ServerFailure._();

  const factory ServerFailure.unknown(String message) = _Unknown;
  const factory ServerFailure.playerNotFound() = _PlayerNotFound;
  const factory ServerFailure.buildingNotFound() = _BuildingNotFound;
  const factory ServerFailure.marketNotFound() = _MarketNotFound;
  const factory ServerFailure.tooManyFactories() = _TooManyFactories;
  const factory ServerFailure.zoneIsBusy() = _ZoneIsBusy;
  const factory ServerFailure.storageAlreadyExists() = _StorageAlreadyExists;
  const factory ServerFailure.notEnoughCurrency() = _NotEnoughCurrency;
  const factory ServerFailure.notEnoughGems() = _NotEnoughGems;
  const factory ServerFailure.factoryAlreadyToggled() = _FactoryAlreadyToggled;
  const factory ServerFailure.notEnoughResources() = _NotEnoughResources;
  const factory ServerFailure.connectionTimedOut() = _ConnectionTimedOut;
  const factory ServerFailure.connectionRefused() = _ConnectionRefused;
  const factory ServerFailure.serverIsDown() = _ServerIsDown;
  const factory ServerFailure.banned(String reason) = _Banned;

  factory ServerFailure.fromError(DioError error) {
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
    if (error.type == DioErrorType.connectionTimeout) {
      return const ServerFailure.connectionTimedOut();
    }
    if (error.type == DioErrorType.connectionError) {
      return const ServerFailure.connectionRefused();
    }
    return ServerFailure.unknown(error.message ?? 'Unknown');
  }

  String getMessage() {
    return when(
      unknown: (message) => 'Unknown error: $message',
      playerNotFound: () => 'Player not found',
      buildingNotFound: () => 'Building not found',
      marketNotFound: () => 'Market not found',
      tooManyFactories: () => 'Too many factories',
      zoneIsBusy: () => 'Zone is busy',
      storageAlreadyExists: () => 'Storage already exists',
      notEnoughCurrency: () => 'Not enough currency',
      factoryAlreadyToggled: () => 'Factory already toggled',
      notEnoughResources: () => 'Not enough resources',
      connectionTimedOut: () => 'Connection timed out',
      connectionRefused: () => 'Connection refused',
      banned: (reason) => 'You have been banned, reason: $reason',
      serverIsDown: () => 'Server is down',
      notEnoughGems: () => 'Not enough gems',
    );
  }
}
