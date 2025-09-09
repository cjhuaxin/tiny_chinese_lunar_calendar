import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/app/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    testWidgets('lightTheme has correct primary color', (tester) async {
      final theme = AppTheme.lightTheme;
      
      expect(theme.colorScheme.primary, const Color(0xFFE53935));
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('darkTheme has correct primary color', (tester) async {
      final theme = AppTheme.darkTheme;
      
      expect(theme.colorScheme.primary, const Color(0xFFEF5350));
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('lightTheme AppBar has Chinese red background', (tester) async {
      final theme = AppTheme.lightTheme;
      
      expect(theme.appBarTheme.backgroundColor, const Color(0xFFE53935));
      expect(theme.appBarTheme.foregroundColor, Colors.white);
      expect(theme.appBarTheme.centerTitle, isTrue);
    });

    testWidgets('lightTheme has proper text colors', (tester) async {
      final theme = AppTheme.lightTheme;
      
      expect(theme.textTheme.headlineLarge?.color, const Color(0xFF424242));
      expect(theme.textTheme.bodyLarge?.color, const Color(0xFF424242));
    });

    testWidgets('theme supports both light and dark modes', (tester) async {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;
      
      expect(lightTheme.colorScheme.brightness, Brightness.light);
      expect(darkTheme.colorScheme.brightness, Brightness.dark);
    });
  });
}
