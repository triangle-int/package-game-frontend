part of 'sidebar_bloc.dart';

@freezed
sealed class SidebarState with _$SidebarState {
  const factory SidebarState.initial({
    required bool isSettingsOpened,
  }) = SidebarStateInitial;
  const factory SidebarState.routes(
    Either<ServerFailure, TruckSchedulesResponse>? schedulesOrFailure, {
    required bool isLoading,
  }) = SidebarStateRoutes;
}
