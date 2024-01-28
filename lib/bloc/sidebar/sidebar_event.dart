part of 'sidebar_bloc.dart';

@freezed
class SidebarEvent with _$SidebarEvent {
  const factory SidebarEvent.routesSelected() = _RoutesSelected;
  const factory SidebarEvent.initialPageSelected() = _InitialPageSelected;
  const factory SidebarEvent.settingsToggled() = _SettingsToggled;
}
