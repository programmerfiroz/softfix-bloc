class LanguageResponse {
    final String res;
    final String message;
    final LanguageData data;

    LanguageResponse({
        required this.res,
        required this.message,
        required this.data
    });

    factory LanguageResponse.fromJson(Map<String, dynamic> json) {
        return LanguageResponse(
            res: json['res'] ?? 'success',
            message: json['message'] ?? '',
            data: LanguageData.fromJson(json['data'] ?? {})
        );
    }
}

class LanguageData {
    final List<LanguageModel> languages;
    final Map<String, Map<String, String>> translations;

    LanguageData({
        required this.languages,
        required this.translations
    });

    factory LanguageData.fromJson(Map<String, dynamic> json) {
        final List<dynamic> languagesJson = json['languages'] ?? [];
        final languages = languagesJson
            .map((lang) => LanguageModel.fromJson(lang))
            .toList();

        final Map<String, dynamic> translationsJson = json['translations'] ?? {};
        final Map<String, Map<String, String>> translations = {};

        translationsJson.forEach((languageCode, translationMap) {
                translations[languageCode] = Map<String, String>.from(
                    translationMap.map((key, value) => MapEntry(key, value.toString()))
                );
            }
        );

        return LanguageData(
            languages: languages,
            translations: translations
        );
    }
}

class LanguageModel {
    final int id;
    final String imageUrl;
    final String languageName;
    final String languageCode;
    final String countryCode;
    final bool isDefault;

    LanguageModel({
        required this.id,
        required this.imageUrl,
        required this.languageName,
        required this.languageCode,
        required this.countryCode,
        this.isDefault = false,
    });

    factory LanguageModel.fromJson(Map<String, dynamic> json) {
        return LanguageModel(
            id: json['id'] ?? 0,
            imageUrl: json['image-url'] ?? '',
            languageName: json['display-name'] ?? '',
            languageCode: json['language-code'] ?? '',
            countryCode: json['country-code'] ?? '',
            isDefault: json['is-default'] ?? false,
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'image-url': imageUrl,
            'display-name': languageName,
            'language-code': languageCode,
            'country-code': countryCode,
            'is-default': isDefault,
        };
    }
}
