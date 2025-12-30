import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/utils/logger.dart';
import '../models/language_model.dart';
import '../services/language_service.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
    LanguageBloc()
        : super(LanguageState(
                languages: [],
                selectedIndex: 0,
                locale: const Locale('en', 'US'),
                isLoading: false,
                errorMessage: null
            )) {
        on<LoadLanguagesEvent>(_onLoadLanguages);
        on<SelectLanguageEvent>(_onSelectLanguage);
        on<ReloadLanguagesEvent>(_onReloadLanguages);
    }

    void _onLoadLanguages(
        LoadLanguagesEvent event, Emitter<LanguageState> emit) async {
        emit(state.copyWith(isLoading: true, errorMessage: null));

        try {
            Logger.i('Loading languages...');

            // Load languages from API or local JSON
            List<LanguageModel> languages = await LanguageService.loadLanguages();

            if (languages.isEmpty) {
                emit(state.copyWith(
                        isLoading: false,
                        errorMessage: 'No languages available'
                    ));
                return;
            }

            Logger.i('Loaded ${languages.length} languages');

            // Get saved language code from preferences
            final savedLanguageCode = SharedPrefs.getString(AppConstants.languagePref);

            int selectedIndex;
            if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
                // Try to find saved language
                selectedIndex = languages.indexWhere(
                    (element) => element.languageCode == savedLanguageCode);

                if (selectedIndex == -1) {
                    // If saved language not found, use default
                    selectedIndex = languages.indexWhere((element) => element.isDefault);
                }
            }
            else {
                // No saved language, use default
                selectedIndex = languages.indexWhere((element) => element.isDefault);
            }

            // Fallback to first language if no default found
            if (selectedIndex == -1) {
                selectedIndex = 0;
                Logger.w('No default language found, using first language');
            }

            final selectedLanguage = languages[selectedIndex];
            Logger.i('Selected language: ${selectedLanguage.languageName} (${selectedLanguage.languageCode})');

            emit(LanguageState(
                    languages: languages,
                    selectedIndex: selectedIndex,
                    locale: Locale(
                        selectedLanguage.languageCode,
                        selectedLanguage.countryCode
                    ),
                    isLoading: false,
                    errorMessage: null
                ));
        }
        catch (e) {
            Logger.e('Error loading languages: $e');
            emit(state.copyWith(
                    isLoading: false,
                    errorMessage: e.toString()
                ));
        }
    }

    void _onSelectLanguage(
        SelectLanguageEvent event, Emitter<LanguageState> emit) {
        try {
            final index = state.languages.indexWhere(
                (element) => element.languageCode == event.language.languageCode);

            if (index == -1) {
                Logger.w('Language not found: ${event.language.languageCode}');
                return;
            }

            final newLocale = Locale(
                event.language.languageCode,
                event.language.countryCode
            );

            // Save selected language to preferences
            SharedPrefs.setString(
                AppConstants.languagePref, event.language.languageCode);

            Logger.i('Language changed to: ${event.language.languageName}');

            emit(state.copyWith(selectedIndex: index, locale: newLocale));
        }
        catch (e) {
            Logger.e('Error selecting language: $e');
        }
    }

    void _onReloadLanguages(
        ReloadLanguagesEvent event, Emitter<LanguageState> emit) async {
        emit(state.copyWith(isLoading: true, errorMessage: null));

        try {
            Logger.i('Reloading languages...');

            // Clear cache and reload
            List<LanguageModel> languages = await LanguageService.reloadLanguages();

            if (languages.isEmpty) {
                emit(state.copyWith(
                        isLoading: false,
                        errorMessage: 'No languages available'
                    ));
                return;
            }

            // Keep current selection if possible
            final currentLanguageCode = state.languages.isNotEmpty &&
                state.selectedIndex < state.languages.length
                ? state.languages[state.selectedIndex].languageCode
                : null;

            int selectedIndex = 0;
            if (currentLanguageCode != null) {
                final index = languages.indexWhere(
                    (element) => element.languageCode == currentLanguageCode);
                if (index != -1) {
                    selectedIndex = index;
                }
            }

            final selectedLanguage = languages[selectedIndex];

            emit(LanguageState(
                    languages: languages,
                    selectedIndex: selectedIndex,
                    locale: Locale(
                        selectedLanguage.languageCode,
                        selectedLanguage.countryCode
                    ),
                    isLoading: false,
                    errorMessage: null
                ));

            Logger.i('Languages reloaded successfully');
        }
        catch (e) {
            Logger.e('Error reloading languages: $e');
            emit(state.copyWith(
                    isLoading: false,
                    errorMessage: e.toString()
                ));
        }
    }
}
