import 'package:flutter/widgets.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/gen/app_localizations.dart';

export 'package:tiny_chinese_lunar_calendar/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
