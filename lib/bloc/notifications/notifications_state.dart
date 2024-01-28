part of 'notifications_bloc.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = _Initial;
  const factory NotificationsState.successNotificationReceived({
    required String message,
  }) = _SuccessNotificationReceived;
  const factory NotificationsState.warningNotificationReceived({
    required String message,
  }) = _WarningNotificationReceived;
  const factory NotificationsState.notificationReceived({
    required String message,
    required String title,
  }) = _NotificationReceived;
}
