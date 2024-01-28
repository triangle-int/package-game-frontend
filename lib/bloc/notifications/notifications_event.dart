part of 'notifications_bloc.dart';

@freezed
class NotificationsEvent with _$NotificationsEvent {
  const factory NotificationsEvent.setup() = _Setup;
  const factory NotificationsEvent.warningAdded(String message) = _WarningAdded;
  const factory NotificationsEvent.successAdded(String message) = _SuccessAdded;
  const factory NotificationsEvent.notificationAdded(
    String title,
    String message,
  ) = _NotificationAdded;
}
