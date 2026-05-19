import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/core/services/joshua_project_service.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/providers/data_providers.dart';

enum SearchTab { countries, missionaries, map }

class AdvancedSearchState {
  final List<JoshuaCountry> allCountries;
  final List<JoshuaCountry> filteredCountries;
  final List<MissionaryData> allMissionaries;
  final List<MissionaryData> filteredMissionaries;
  final String query;
  final SearchTab tab;
  final String categoryFilter;
  final bool isLoading;

  AdvancedSearchState({
    this.allCountries = const [],
    this.filteredCountries = const [],
    this.allMissionaries = const [],
    this.filteredMissionaries = const [],
    this.query = "",
    this.tab = SearchTab.countries,
    this.categoryFilter = "",
    this.isLoading = true,
  });

  AdvancedSearchState copyWith({
    List<JoshuaCountry>? allCountries,
    List<JoshuaCountry>? filteredCountries,
    List<MissionaryData>? allMissionaries,
    List<MissionaryData>? filteredMissionaries,
    String? query,
    SearchTab? tab,
    String? categoryFilter,
    bool? isLoading,
  }) {
    return AdvancedSearchState(
      allCountries: allCountries ?? this.allCountries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      allMissionaries: allMissionaries ?? this.allMissionaries,
      filteredMissionaries: filteredMissionaries ?? this.filteredMissionaries,
      query: query ?? this.query,
      tab: tab ?? this.tab,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AdvancedSearchNotifier extends StateNotifier<AdvancedSearchState> {
  final Ref _ref;

  AdvancedSearchNotifier(this._ref) : super(AdvancedSearchState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    
    final countriesAsync = await _ref.read(countriesProvider.future);
    final missionariesAsync = await _ref.read(allMissionariesProvider.future);

    state = state.copyWith(
      allCountries: countriesAsync,
      filteredCountries: countriesAsync,
      allMissionaries: missionariesAsync,
      filteredMissionaries: missionariesAsync,
      isLoading: false,
    );
  }

  void setTab(SearchTab tab) {
    state = state.copyWith(tab: tab);
    _applyFilters();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
    _applyFilters();
  }

  void setCategory(String category) {
    state = state.copyWith(categoryFilter: category);
    _applyFilters();
  }

  void _applyFilters() {
    final query = state.query.toLowerCase();
    
    if (state.tab == SearchTab.countries || state.tab == SearchTab.map) {
      final filtered = state.allCountries.where((c) {
        return c.name.toLowerCase().contains(query) || 
               c.region.toLowerCase().contains(query);
      }).toList();
      state = state.copyWith(filteredCountries: filtered);
    } else {
      final query = state.query.toLowerCase();
      final cat = state.categoryFilter;
      final filtered = state.allMissionaries.where((m) {
        if (cat.isNotEmpty && m.category != cat) return false;
        return m.name.toLowerCase().contains(query) || 
               m.location.toLowerCase().contains(query) ||
               m.headline.toLowerCase().contains(query);
      }).toList();
      state = state.copyWith(filteredMissionaries: filtered);
    }
  }
}

final advancedSearchProvider = StateNotifierProvider<AdvancedSearchNotifier, AdvancedSearchState>((ref) {
  return AdvancedSearchNotifier(ref);
});
