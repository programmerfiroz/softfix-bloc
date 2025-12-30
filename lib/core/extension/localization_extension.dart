import 'package:flutter/widgets.dart';
import '../../../main.dart';
import '../../features/translations/app_localizations.dart';

extension LocalizationExtension on String {
  String tr(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) return this;
    return loc.translate(this);
  }

  String get trGlobal {
    final loc = rootScaffoldMessengerKey.currentContext != null
        ? AppLocalizations.of(rootScaffoldMessengerKey.currentContext!)
        : null;
    return loc?.translate(this) ?? this;
  }
}

