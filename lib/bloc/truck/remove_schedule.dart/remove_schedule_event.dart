part of 'remove_schedule_bloc.dart';

@freezed
class RemoveScheduleEvent with _$RemoveScheduleEvent {
  const factory RemoveScheduleEvent.remove(int scheduleId) =
      RemoveScheduleEventRemove;
  const factory RemoveScheduleEvent.reset() = RemoveScheduleEventReset;
}
