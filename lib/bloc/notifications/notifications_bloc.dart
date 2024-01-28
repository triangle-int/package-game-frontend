import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/notifications/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';
part 'notifications_bloc.freezed.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  StreamSubscription? _notificationsSubscription;

  NotificationsBloc(this._repository)
      : super(const NotificationsState.initial()) {
    on<NotificationsEvent>((event, emit) async {
      await event.map(
        warningAdded: (e) async {
          emit(
            NotificationsState.warningNotificationReceived(message: e.message),
          );
          emit(const NotificationsState.initial());
        },
        successAdded: (e) async {
          emit(
            NotificationsState.successNotificationReceived(message: e.message),
          );
          emit(const NotificationsState.initial());
        },
        notificationAdded: (e) async {
          emit(
            NotificationsState.notificationReceived(
              title: e.title,
              message: e.message,
            ),
          );
          emit(const NotificationsState.initial());
        },
        setup: (_) async {
          final failureOrUnit = await _repository.setup();

          failureOrUnit.fold(
            (failure) {
              emit(
                const NotificationsState.warningNotificationReceived(
                  message: 'Failed to setup notifications',
                ),
              );
              emit(const NotificationsState.initial());
            },
            (_) {
              _notificationsSubscription?.cancel();
              _notificationsSubscription =
                  _repository.notificationsStream().listen((notification) {
                notification.map(
                  notification: (n) => add(
                    NotificationsEvent.notificationAdded(n.title, n.message),
                  ),
                  success: (n) =>
                      add(NotificationsEvent.successAdded(n.message)),
                  warning: (n) =>
                      add(NotificationsEvent.warningAdded(n.message)),
                );
              });
            },
          );
        },
      );
    });
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
