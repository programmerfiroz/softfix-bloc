import 'package:flutter/material.dart';
import '../models/language_model.dart';

class LanguageState {
  final List<LanguageModel> languages;
  final int selectedIndex;
  final Locale locale;
  final bool isLoading;
  final String? errorMessage;

  const LanguageState({
    required this.languages,
    required this.selectedIndex,
    required this.locale,
    this.isLoading = false,
    this.errorMessage,
  });

  LanguageState copyWith({
    List<LanguageModel>? languages,
    int? selectedIndex,
    Locale? locale,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LanguageState(
      languages: languages ?? this.languages,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}