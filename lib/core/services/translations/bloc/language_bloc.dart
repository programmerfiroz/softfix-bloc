import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/constants/image_constants.dart';
import '../../storage/shared_prefs.dart';
import '../language_model.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc()
      : super(LanguageState(
    languages: [],
    selectedIndex: 0,
    locale: const Locale('en', 'US'),
  )) {
    on<LoadLanguagesEvent>(_onLoadLanguages);
    on<SelectLanguageEvent>(_onSelectLanguage);
  }

  void _onLoadLanguages(
      LoadLanguagesEvent event, Emitter<LanguageState> emit) async {
    final languages = [
      LanguageModel(
        imageUrl: ImageConstants.english,
        languageName: 'English',
        languageCode: 'en',
        countryCode: 'US',
      ),
      LanguageModel(
        imageUrl: ImageConstants.hindi,
        languageName: 'हिन्दी',
        languageCode: 'hi',
        countryCode: 'IN',
      ),
    ];

    // Load selected language from storage
    final languageCode = SharedPrefs.getString(AppConstants.language) ?? 'en';
    final selectedIndex =
    languages.indexWhere((element) => element.languageCode == languageCode);

    emit(LanguageState(
      languages: languages,
      selectedIndex: selectedIndex != -1 ? selectedIndex : 0,
      locale: Locale(
        languages[selectedIndex != -1 ? selectedIndex : 0].languageCode,
        languages[selectedIndex != -1 ? selectedIndex : 0].countryCode,
      ),
    ));
  }

  void _onSelectLanguage(
      SelectLanguageEvent event, Emitter<LanguageState> emit) {
    final index = state.languages
        .indexWhere((element) => element.languageCode == event.language.languageCode);

    if (index == -1) return;

    final newLocale = Locale(
      event.language.languageCode,
      event.language.countryCode,
    );

    // Save in SharedPrefs
    SharedPrefs.setString(AppConstants.language, event.language.languageCode);

    emit(state.copyWith(selectedIndex: index, locale: newLocale));
  }
}
