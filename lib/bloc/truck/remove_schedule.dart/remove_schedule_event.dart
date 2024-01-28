part of 'remove_schedule_bloc.dart';

@freezed
class RemoveScheduleEvent with _$RemoveScheduleEvent {
  const factory RemoveScheduleEvent.removeSchedule(int scheduleId) =
      _RemoveSchedule;
  const factory RemoveScheduleEvent.reset() = _Reset;
}
