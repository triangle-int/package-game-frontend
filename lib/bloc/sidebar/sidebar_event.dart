part of 'sidebar_bloc.dart';

@freezed
sealed class SidebarEvent with _$SidebarEvent {
  const factory SidebarEvent.routesSelected() = SidebarEventRoutesSelected;
  const factory SidebarEvent.initialPageSelected() =
      SidebarEventInitialPageSelected;
  const factory SidebarEvent.settingsToggled() = SidebarEventSettingsToggled;
}
