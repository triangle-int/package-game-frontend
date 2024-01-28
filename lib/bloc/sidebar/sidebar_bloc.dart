import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';
import 'package:package_flutter/domain/truck/truck_schedules_response.dart';

part 'sidebar_bloc.freezed.dart';
part 'sidebar_event.dart';
part 'sidebar_state.dart';

class SidebarBloc extends Bloc<SidebarEvent, SidebarState> {
  final TruckRepository _truckRepository;

  SidebarBloc(this._truckRepository)
      : super(const SidebarState.initial(isSettingsOpened: false)) {
    on<SidebarEvent>((event, emit) async {
      await event.map(
        routesSelected: (_) async {
          emit(
            state.map(
              initial: (_) => const SidebarState.routes(
                null,
                isLoading: true,
              ),
              routes: (s) => s.copyWith(isLoading: true),
            ),
          );
          final schedulesOrFailure = await _truckRepository.getSchedules();
          emit(SidebarState.routes(schedulesOrFailure, isLoading: false));
        },
        initialPageSelected: (_) async =>
            emit(const SidebarState.initial(isSettingsOpened: false)),
        settingsToggled: (_) async => state.mapOrNull(
          initial: (s) =>
              emit(s.copyWith(isSettingsOpened: !s.isSettingsOpened)),
        ),
      );
    });
  }
}
