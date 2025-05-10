import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/inventory/inventory.dart';
import 'package:package_flutter/domain/inventory/inventory_failure.dart';
import 'package:package_flutter/domain/socket/socket_repository.dart';
import 'package:package_flutter/domain/user/create_user_failure.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/domain/user/user_on_map.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(
    ref.watch(dioProvider),
    ref.watch(socketRepositoryProvider),
  );
}

class UserRepository {
  final Dio _dio;
  final SocketRepository _socketRepository;

  final _userStreamController = StreamController<User>.broadcast();
  final _inventoryStreamController =
      StreamController<Either<InventoryFailure, Inventory>>.broadcast();

  User? user;

  UserRepository(this._dio, this._socketRepository);

  Stream<Either<InventoryFailure, Inventory>> getInventoryUpdates() {
    return _inventoryStreamController.stream;
  }

  Stream<User> getMe() {
    return MergeStream([
      _userStreamController.stream,
      Stream.fromFuture(_getMyUser()),
      _socketRepository.getUserUpdates(),
    ]);
  }

  Future<User> _getMyUser() async {
    final response = await _dio.get('/user/me');
    user = User.fromJson(response.data as Map<String, dynamic>);

    return user!;
  }

  Future<Either<CreateUserFailure, Unit>> createUser({
    required String nickname,
    required String avatar,
  }) async {
    final geolocation = await Geolocator.getLastKnownPosition();
    try {
      final response = await _dio.post(
        '/user/create',
        data: {
          'nickname': nickname,
          'avatar': avatar,
          'location': '${geolocation!.latitude},${geolocation.longitude}'
        },
      );
      Logger().d(response.data);
      final user = User.fromJson(response.data as Map<String, dynamic>);
      _userStreamController.add(user);
      Logger().d('User added to the stream');

      return right(unit);
    } on DioException catch (e) {
      Logger().d(e.requestOptions.headers);
      if (e.response?.statusCode == 403) {
        if (e.response!.data['message'] == 'nicknameTaken') {
          return left(const CreateUserFailure.nicknameAlreadyInUse());
        }
        if (e.response!.data['message'] == 'incorrectToken') {
          return left(const CreateUserFailure.invalidAccessToken());
        }
      }
      if (e.response?.statusCode == 400) {
        final messages = e.response!.data['message'] as List<dynamic>;
        if (messages.contains(
          'nickname must be longer than or equal to 3 characters',
        )) {
          return left(const CreateUserFailure.tooShortNickname(3));
        }
        if (messages.contains('avatar should not be empty')) {
          return left(const CreateUserFailure.noAvatar());
        }
        return left(
          CreateUserFailure.serverFailure(
            e.response!.data['message'].toString(),
          ),
        );
      }
      return left(CreateUserFailure.serverFailure(e.message!));
    } catch (e) {
      return left(CreateUserFailure.serverFailure(e.toString()));
    }
  }

  Future<List<UserOnMap>> getUsersInBounds({
    required LatLng minCoords,
    required LatLng maxCoords,
  }) async {
    final response = await _dio.get(
      '/user/get-users-in-bounds',
      queryParameters: {
        'minCoords': '${minCoords.latitude},${minCoords.longitude}',
        'maxCoords': '${maxCoords.latitude},${maxCoords.longitude}',
      },
    );
    final users = (response.data as List)
        .map((json) => UserOnMap.fromJson(json as Map<String, dynamic>))
        .toList();
    // Logger().d('Users in bounds: $users');
    return users;
  }

  Future<void> setLocation(LatLng location) async {
    final response = await _dio.post(
      '/user/set-location',
      data: {'location': '${location.latitude},${location.longitude}'},
    );
    Logger().d('Location updated on server');
    final user = User.fromJson(response.data as Map<String, dynamic>);
    _userStreamController.add(user);
  }
}
