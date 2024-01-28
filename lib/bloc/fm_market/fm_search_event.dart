part of 'fm_search_bloc.dart';

@freezed
class FmSearchEvent with _$FmSearchEvent {
  const factory FmSearchEvent.openSearch() = _OpenSearch;
  const factory FmSearchEvent.closeSearch() = _CloseSearch;
  const factory FmSearchEvent.nicknameChanged(String nickname) =
      _NicknameChanged;
  const factory FmSearchEvent.addFilter(String resourceName) = _AddFilter;
  const factory FmSearchEvent.removeFilter(String resourceName) = _RemoveFilter;
  const factory FmSearchEvent.clearFilters() = _ClearFilters;
  const factory FmSearchEvent.search() = _Search;
  const factory FmSearchEvent.loadMore() = _LoadMore;
}
