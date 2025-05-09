part of 'notifications_bloc.dart';

@freezed
sealed class NotificationsEvent with _$NotificationsEvent {
  const factory NotificationsEvent.setup() = NotificationsEventSetup;
  const factory NotificationsEvent.warningAdded(String message) =
      NotificationsEventWarningAdded;
  const factory NotificationsEvent.successAdded(String message) =
      NotificationsEventSuccessAdded;
  const factory NotificationsEvent.added(
    String title,
    String message,
  ) = NotificationsEventAdded;
}
