import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/firebase_messaging_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/notifications/notification_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_repository.g.dart';

@riverpod
NotificationsRepository notificationsRepository(
    NotificationsRepositoryRef ref) {
  return NotificationsRepository(
    ref.watch(firebaseMessagingProvider),
    ref.watch(dioProvider),
  );
}

class NotificationsRepository {
  final FirebaseMessaging _firebaseMessaging;
  final Dio _dio;

  NotificationsRepository(this._firebaseMessaging, this._dio);

  Future<Either<ServerFailure, Unit>> setup() async {
    try {
      await _firebaseMessaging.requestPermission();
      final token = await _firebaseMessaging.getToken();
      Logger().d('FCM Token: $token');
      await _dio.post(
        '/user/set-fcm-token',
        data: {
          'fcmToken': token,
        },
      );
      return right(unit);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Stream<NotificationData> notificationsStream() {
    return FirebaseMessaging.onMessage
        .where((message) => message.notification != null)
        .map(
          (message) => NotificationData.notification(
            title: message.notification!.title!,
            message: message.notification!.body!,
          ),
        );
  }
}
