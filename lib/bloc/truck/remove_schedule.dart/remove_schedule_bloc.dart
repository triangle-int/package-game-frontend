import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';

part 'remove_schedule_event.dart';
part 'remove_schedule_state.dart';
part 'remove_schedule_bloc.freezed.dart';

class RemoveScheduleBloc
    extends Bloc<RemoveScheduleEvent, RemoveScheduleState> {
  final TruckRepository _repository;

  RemoveScheduleBloc(this._repository)
      : super(const RemoveScheduleState.initial()) {
    on<RemoveScheduleEvent>((event, emit) async {
      await event.map(
        removeSchedule: (e) async {
          emit(const RemoveScheduleState.loadInProgress());

          final failureOrUnit = await _repository.removeSchedule(e.scheduleId);

          failureOrUnit.fold(
            (failure) => emit(RemoveScheduleState.loadFailure(failure)),
            (_) => emit(const RemoveScheduleState.loadSuccess()),
          );
        },
        reset: (_) async => emit(const RemoveScheduleState.initial()),
      );
    });
  }
}
