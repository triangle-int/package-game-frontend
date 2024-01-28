part of 'remove_schedule_bloc.dart';

@freezed
class RemoveScheduleState with _$RemoveScheduleState {
  const factory RemoveScheduleState.initial() = _Initial;
  const factory RemoveScheduleState.loadInProgress() = _LoadInProgress;
  const factory RemoveScheduleState.loadFailure(ServerFailure failure) =
      _LoadFailure;
  const factory RemoveScheduleState.loadSuccess() = _LoadSuccess;
}
