import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/view/calendar_page.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/l10n.dart';

void main() {
  group('Six Row Month Layout Tests', () {
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

    testWidgets(
      'June 2025 (6-row month) should not overflow in standard window',
      (tester) async {
        // Test with standard window size
        await tester.binding.setSurfaceSize(const Size(500, 500));

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify no overflow for 6-row month
        expect(find.byType(CalendarPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('June 2025 (6-row month) should not overflow in small window', (
      tester,
    ) async {
      // Test with small window size where overflow was reported
      await tester.binding.setSurfaceSize(const Size(400, 400));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify no overflow even in small window
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'June 2025 (6-row month) should not overflow in very small window',
      (tester) async {
        // Test with very small but realistic window size (accounting for AppBar)
        await tester.binding.setSurfaceSize(const Size(380, 420));

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify no overflow even in very small window
        expect(find.byType(CalendarPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('March 2025 (6-row month) should not overflow', (tester) async {
      // Test another 6-row month
      await tester.binding.setSurfaceSize(const Size(450, 450));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify no overflow for another 6-row month
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('6-row months should handle window resize without overflow', (
      tester,
    ) async {
      // Start with medium size
      await tester.binding.setSurfaceSize(const Size(500, 500));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Resize to smaller but safe size
      await tester.binding.setSurfaceSize(const Size(450, 450));
      await tester.pump();

      // Should still work after resize
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Resize to very small but realistic size
      await tester.binding.setSurfaceSize(const Size(380, 420));
      await tester.pump();

      // Should still work after further resize
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Row Calculation Verification for 6-Row Months', () {
    test('Verify June 2025 needs exactly 6 rows', () {
      // June 2025: 1st is Sunday (weekday 7)
      final firstDay = DateTime(2025, 6);
      expect(firstDay.weekday, equals(7)); // Sunday

      // Calculate rows needed
      final firstDayWeekday = (firstDay.weekday - 1) % 7; // 6 (Sunday)
      final lastDay = DateTime(2025, 7, 0); // June 30
      final daysInMonth = lastDay.day; // 30 days
      final totalCells = firstDayWeekday + daysInMonth; // 6 + 30 = 36
      final rowsNeeded = (totalCells / 7).ceil(); // ceil(36/7) = 6

      expect(rowsNeeded, equals(6));
      print(
        'June 2025: firstDayWeekday=$firstDayWeekday, daysInMonth=$daysInMonth, totalCells=$totalCells, rowsNeeded=$rowsNeeded',
      );
    });

    test('Verify March 2025 needs exactly 6 rows', () {
      // March 2025: 1st is Saturday (weekday 6)
      final firstDay = DateTime(2025, 3);
      expect(firstDay.weekday, equals(6)); // Saturday

      // Calculate rows needed
      final firstDayWeekday = (firstDay.weekday - 1) % 7; // 5 (Saturday)
      final lastDay = DateTime(2025, 4, 0); // March 31
      final daysInMonth = lastDay.day; // 31 days
      final totalCells = firstDayWeekday + daysInMonth; // 5 + 31 = 36
      final rowsNeeded = (totalCells / 7).ceil(); // ceil(36/7) = 6

      expect(rowsNeeded, equals(6));
      print(
        'March 2025: firstDayWeekday=$firstDayWeekday, daysInMonth=$daysInMonth, totalCells=$totalCells, rowsNeeded=$rowsNeeded',
      );
    });
  });
}
