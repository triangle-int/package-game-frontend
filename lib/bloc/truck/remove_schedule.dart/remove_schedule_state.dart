part of 'remove_schedule_bloc.dart';

@freezed
sealed class RemoveScheduleState with _$RemoveScheduleState {
  const factory RemoveScheduleState.initial() = RemoveScheduleStateInitial;
  const factory RemoveScheduleState.loadInProgress() =
      RemoveScheduleStateLoadInProgress;
  const factory RemoveScheduleState.loadFailure(ServerFailure failure) =
      RemoveScheduleStateLoadFailure;
  const factory RemoveScheduleState.loadSuccess() =
      RemoveScheduleStateLoadSuccess;
}
