part of 'fm_search_bloc.dart';

@freezed
sealed class FmSearchEvent with _$FmSearchEvent {
  const factory FmSearchEvent.openSearch() = FmSearchEventOpenSearch;
  const factory FmSearchEvent.closeSearch() = FmSearchEventCloseSearch;
  const factory FmSearchEvent.nicknameChanged(String nickname) =
      FmSearchEventNicknameChanged;
  const factory FmSearchEvent.addFilter(String resourceName) =
      FmSearchEventAddFilter;
  const factory FmSearchEvent.removeFilter(String resourceName) =
      FmSearchEventRemoveFilter;
  const factory FmSearchEvent.clearFilters() = FmSearchEventClearFilters;
  const factory FmSearchEvent.search() = FmSearchEventSearch;
  const factory FmSearchEvent.loadMore() = FmSearchEventLoadMore;
}
