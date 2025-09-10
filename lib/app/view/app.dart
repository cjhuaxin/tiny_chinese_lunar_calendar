import 'package:flutter/material.dart';
import 'package:tiny_chinese_lunar_calendar/app/theme/app_theme.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/calendar.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/gen/app_localizations.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale;

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // 强制使用亮色主题，不跟随系统
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CalendarPage(onLanguageChanged: _changeLanguage),
    );
  }
}
