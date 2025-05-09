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
      switch (event) {
        case SidebarEventRoutesSelected():
          emit(switch (state) {
            SidebarStateInitial() => const SidebarState.routes(
                null,
                isLoading: true,
              ),
            SidebarStateRoutes(:final copyWith) => copyWith(isLoading: true),
          });
          final schedulesOrFailure = await _truckRepository.getSchedules();
          emit(SidebarState.routes(schedulesOrFailure, isLoading: false));
        case SidebarEventInitialPageSelected():
          emit(const SidebarState.initial(isSettingsOpened: false));
        case SidebarEventSettingsToggled():
          switch (state) {
            case SidebarStateInitial(:final copyWith, :final isSettingsOpened):
              emit(copyWith(isSettingsOpened: !isSettingsOpened));
            default:
              break;
          }
      }
    });
  }
}
