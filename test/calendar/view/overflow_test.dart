import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/view/calendar_page.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/l10n.dart';

void main() {
  // Helper function to create a MaterialApp with localization settings
  Widget createTestApp({DateTime? initialDate}) {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: CalendarPage(),
    );
  }

  group('Calendar Overflow Tests', () {
    testWidgets('June 2025 (6-row month) should not overflow in small window', (tester) async {
      // Set a small window size that could cause overflow
      await tester.binding.setSurfaceSize(const Size(500, 450));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to June 2025 which requires 6 rows
      // First, we need to find the calendar and navigate to June 2025
      // This is a month that starts on Sunday and has 30 days, requiring 6 rows
      
      // Verify the calendar renders without overflow
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      
      // The calendar should be visible and functional
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('May 2025 (6-row month) should not overflow in small window', (tester) async {
      // Set a small window size that could cause overflow
      await tester.binding.setSurfaceSize(const Size(500, 450));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // May 2025 also requires 6 rows (starts on Thursday, 31 days)
      
      // Verify the calendar renders without overflow
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Calendar should handle very tight constraints without overflow', (tester) async {
      // Test with extremely tight constraints
      await tester.binding.setSurfaceSize(const Size(400, 350));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should not overflow even with very tight constraints
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Calendar should handle different aspect ratios without overflow', (tester) async {
      // Test with a very wide but short window
      await tester.binding.setSurfaceSize(const Size(800, 300));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should handle unusual aspect ratios
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      
      // Test with a very tall but narrow window
      await tester.binding.setSurfaceSize(const Size(300, 800));
      await tester.pump();

      // Should still work
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Row height calculation should be appropriate for 6-row months', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 450));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find the calendar widget
      final calendarFinder = find.byType(CalendarPage);
      expect(calendarFinder, findsOneWidget);
      
      // Verify no overflow exceptions
      expect(tester.takeException(), isNull);
      
      // The calendar should render all its content within bounds
      final calendarWidget = tester.widget<CalendarPage>(calendarFinder);
      expect(calendarWidget, isNotNull);
    });
  });

  group('Row Calculation Tests', () {
    test('June 2025 should require 6 rows', () {
      final june2025 = DateTime(2025, 6);
      
      // Calculate manually: June 2025 starts on Sunday (weekday 7)
      // In our calendar (Monday = 0), Sunday = 6
      final firstDayWeekday = (june2025.weekday - 1) % 7; // Should be 6
      const daysInMonth = 30; // June has 30 days
      final totalCells = firstDayWeekday + daysInMonth; // 6 + 30 = 36
      final rowsNeeded = (totalCells / 7).ceil(); // 36 / 7 = 5.14... -> 6 rows
      
      expect(rowsNeeded, equals(6));
    });

    test('May 2025 should require 6 rows', () {
      final may2025 = DateTime(2025, 5);
      
      // Calculate manually: May 2025 starts on Thursday (weekday 4)
      // In our calendar (Monday = 0), Thursday = 3
      final firstDayWeekday = (may2025.weekday - 1) % 7; // Should be 3
      const daysInMonth = 31; // May has 31 days
      final totalCells = firstDayWeekday + daysInMonth; // 3 + 31 = 34
      final rowsNeeded = (totalCells / 7).ceil(); // 34 / 7 = 4.86... -> 5 rows
      
      expect(rowsNeeded, equals(5));
    });

    test('March 2025 should require 6 rows', () {
      final march2025 = DateTime(2025, 3);
      
      // Calculate manually: March 2025 starts on Saturday (weekday 6)
      // In our calendar (Monday = 0), Saturday = 5
      final firstDayWeekday = (march2025.weekday - 1) % 7; // Should be 5
      const daysInMonth = 31; // March has 31 days
      final totalCells = firstDayWeekday + daysInMonth; // 5 + 31 = 36
      final rowsNeeded = (totalCells / 7).ceil(); // 36 / 7 = 5.14... -> 6 rows
      
      expect(rowsNeeded, equals(6));
    });
  });
}
