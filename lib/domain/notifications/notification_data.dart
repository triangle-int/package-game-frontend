import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_data.freezed.dart';

@freezed
sealed class NotificationData with _$NotificationData {
  const factory NotificationData.warning({
    required String message,
  }) = NotificationDataWarning;
  const factory NotificationData.success({
    required String message,
  }) = NotificationDataSuccess;
  const factory NotificationData.notification({
    required String title,
    required String message,
  }) = NotificationDataNotification;
}
