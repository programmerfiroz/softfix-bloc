import 'package:flutter/material.dart';

import '../language_model.dart';

class LanguageState {
  final List<LanguageModel> languages;
  final int selectedIndex;
  final Locale locale;

  const LanguageState({
    required this.languages,
    required this.selectedIndex,
    required this.locale,
  });

  LanguageState copyWith({
    List<LanguageModel>? languages,
    int? selectedIndex,
    Locale? locale,
  }) {
    return LanguageState(
      languages: languages ?? this.languages,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      locale: locale ?? this.locale,
    );
  }
}
