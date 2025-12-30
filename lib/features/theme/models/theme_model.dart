import 'package:flutter/material.dart';

class ThemeModel {
    final int id;
    final String name;
    final Color primaryColor;
    final Color secondaryColor;
    final Color darkPrimaryColor;
    final Color darkSecondaryColor;
    final bool isDefault;

    ThemeModel({
        required this.id,
        required this.name,
        required this.primaryColor,
        required this.secondaryColor,
        required this.darkPrimaryColor,
        required this.darkSecondaryColor,
        required this.isDefault
    });

    factory ThemeModel.fromJson(Map<String, dynamic> json) {
        return ThemeModel(
            id: json['id'],
            name: json['name'] ?? '',
            primaryColor: _hexToColor(json['primary-color']),
            secondaryColor: _hexToColor(json['secondary-color']),
            darkPrimaryColor: _hexToColor(json['dark-primary-color']),
            darkSecondaryColor: _hexToColor(json['dark-secondary-color']),
            isDefault: json['is-default'] ?? false
        );
    }

    static Color _hexToColor(String hexString) {
        final buffer = StringBuffer();
        if (hexString.length == 6 || hexString.length == 7) {
            buffer.write('ff');
        }
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'primary-color': _colorToHex(primaryColor),
            'secondary-color': _colorToHex(secondaryColor),
            'dark-primary-color': _colorToHex(darkPrimaryColor),
            'dark-secondary-color': _colorToHex(darkSecondaryColor),
            'is-default': isDefault
        };
    }

    static String _colorToHex(Color color) {
        return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    }
}

class ThemeResponse {
    final String res;
    final String message;
    final List<ThemeModel> data;

    ThemeResponse({
        required this.res,
        required this.message,
        required this.data
    });

    factory ThemeResponse.fromJson(Map<String, dynamic> json) {
        return ThemeResponse(
            res: json['res'],
            message: json['message'],
            data: (json['data'] as List)
                .map((theme) => ThemeModel.fromJson(theme))
                .toList()
        );
    }
}
