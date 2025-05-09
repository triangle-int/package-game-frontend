import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/notifications/notification_data.dart';
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
      switch (event) {
        case NotificationsEventWarningAdded(:final message):
          emit(
            NotificationsState.warningReceived(message: message),
          );
          emit(const NotificationsState.initial());
        case NotificationsEventSuccessAdded(:final message):
          emit(
            NotificationsState.successReceived(message: message),
          );
          emit(const NotificationsState.initial());
        case NotificationsEventAdded(:final title, :final message):
          emit(
            NotificationsState.received(
              title: title,
              message: message,
            ),
          );
          emit(const NotificationsState.initial());
        case NotificationsEventSetup():
          final failureOrUnit = await _repository.setup();

          failureOrUnit.fold(
            (failure) {
              emit(
                const NotificationsState.warningReceived(
                  message: 'Failed to setup notifications',
                ),
              );
              emit(const NotificationsState.initial());
            },
            (_) {
              _notificationsSubscription?.cancel();
              _notificationsSubscription =
                  _repository.notificationsStream().listen((notification) {
                switch (notification) {
                  case NotificationDataNotification(
                      :final title,
                      :final message
                    ):
                    add(
                      NotificationsEvent.added(title, message),
                    );
                  case NotificationDataSuccess(:final message):
                    add(NotificationsEvent.successAdded(message));
                  case NotificationDataWarning(:final message):
                    add(NotificationsEvent.warningAdded(message));
                }
              });
            },
          );
      }
    });
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
