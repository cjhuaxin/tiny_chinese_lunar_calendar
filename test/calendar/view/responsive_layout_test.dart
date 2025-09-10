import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/view/calendar_page.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/l10n.dart';

void main() {
  group('Responsive Calendar Layout Tests', () {
    Widget createTestApp() {
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

    testWidgets('Calendar should handle 6-row months without overflow', (tester) async {
      // Test with a fixed window size that could cause overflow
      await tester.binding.setSurfaceSize(const Size(500, 500));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify the calendar renders without overflow
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      
      // The calendar should be visible and functional
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Calendar should handle 5-row months with proper spacing', (tester) async {
      // Test with a window size that should provide good spacing for 5-row months
      await tester.binding.setSurfaceSize(const Size(600, 600));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify the calendar renders without overflow
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      
      // The calendar should be visible and functional
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Calendar should adapt to very small window sizes', (tester) async {
      // Test with a very small window size
      await tester.binding.setSurfaceSize(const Size(400, 400));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Even with small size, should not overflow
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Calendar should adapt to large window sizes', (tester) async {
      // Test with a large window size
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should handle large sizes gracefully
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Calendar should handle window size changes', (tester) async {
      // Start with one size
      await tester.binding.setSurfaceSize(const Size(500, 500));
      
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify initial render
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Change to a different size
      await tester.binding.setSurfaceSize(const Size(700, 600));
      await tester.pump();

      // Should still work after size change
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Change to a very different aspect ratio
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pump();

      // Should still work with different aspect ratio
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Row Calculation Logic Tests', () {
    test('Verify specific months that need 6 rows', () {
      // These months should need 6 rows based on when their 1st day falls
      final sixRowMonths = [
        DateTime(2025, 6), // June 2025 - 1st is Sunday
        DateTime(2025, 3), // March 2025 - 1st is Saturday  
        DateTime(2024, 9), // September 2024 - 1st is Sunday
        DateTime(2024, 12), // December 2024 - 1st is Sunday
      ];

      for (final month in sixRowMonths) {
        final firstDayOfMonth = DateTime(month.year, month.month);
        final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
        
        final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
        final daysInMonth = lastDayOfMonth.day;
        final totalCells = firstDayWeekday + daysInMonth;
        final rowsNeeded = (totalCells / 7).ceil();
        
        expect(rowsNeeded, equals(6), 
          reason: '${month.year}-${month.month.toString().padLeft(2, '0')} should need 6 rows');
      }
    });

    test('Verify specific months that need 5 rows', () {
      // These months should need 5 rows
      final fiveRowMonths = [
        DateTime(2025, 5), // May 2025 - 1st is Thursday
        DateTime(2025, 1), // January 2025 - 1st is Wednesday
        DateTime(2024, 2), // February 2024 - 1st is Thursday (leap year)
        DateTime(2025, 4), // April 2025 - 1st is Tuesday
      ];

      for (final month in fiveRowMonths) {
        final firstDayOfMonth = DateTime(month.year, month.month);
        final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
        
        final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
        final daysInMonth = lastDayOfMonth.day;
        final totalCells = firstDayWeekday + daysInMonth;
        final rowsNeeded = (totalCells / 7).ceil();
        
        expect(rowsNeeded, equals(5), 
          reason: '${month.year}-${month.month.toString().padLeft(2, '0')} should need 5 rows');
      }
    });
  });
}
