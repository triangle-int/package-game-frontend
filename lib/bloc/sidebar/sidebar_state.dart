part of 'sidebar_bloc.dart';

@freezed
class SidebarState with _$SidebarState {
  const factory SidebarState.initial({
    required bool isSettingsOpened,
  }) = _Initial;
  const factory SidebarState.routes(
    Either<ServerFailure, TruckSchedulesResponse>? schedulesOrFailure, {
    required bool isLoading,
  }) = _Routes;
}
