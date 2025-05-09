part of 'notifications_bloc.dart';

@freezed
sealed class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = NotificationsStateInitial;
  const factory NotificationsState.successReceived({
    required String message,
  }) = NotificationsStateSuccessReceived;
  const factory NotificationsState.warningReceived({
    required String message,
  }) = NotificationsStateWarningReceived;
  const factory NotificationsState.received({
    required String message,
    required String title,
  }) = NotificationsStateReceived;
}
