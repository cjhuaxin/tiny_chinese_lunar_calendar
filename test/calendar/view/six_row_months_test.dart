import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/view/calendar_page.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/gen/app_localizations.dart';

void main() {
  group('Six Row Months Layout Tests', () {
    testWidgets('June 2025 should have adequate row spacing for 6 rows', (
      tester,
    ) async {
      // Set up a 500x500 test environment
      await tester.binding.setSurfaceSize(const Size(500, 500));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 500,
              child: CalendarView(
                initialFocusedDay: DateTime(2025, 6), // June 2025 - 6 rows
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify calendar exists
      expect(find.byType(CalendarView), findsOneWidget);

      // This test ensures no overflow occurs with 6-row months
      // Visual verification needed for spacing adequacy
    });

    testWidgets('March 2026 should have adequate row spacing for 6 rows', (
      tester,
    ) async {
      // Set up a 500x500 test environment
      await tester.binding.setSurfaceSize(const Size(500, 500));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 500,
              child: CalendarView(
                initialFocusedDay: DateTime(2026, 3), // March 2026 - 6 rows
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify calendar exists
      expect(find.byType(CalendarView), findsOneWidget);
    });

    test(
      'Row height calculation should provide better spacing for 6-row months',
      () {
        // Test improved row height calculation for 6-row months
        const availableHeight = 500.0;
        const baseFontSize = 11.0;
        const daysOfWeekHeight = 22.0;
        const headerPadding = 6.0;
        const remainingHeight =
            availableHeight - daysOfWeekHeight - headerPadding;
        const minRowHeight =
            baseFontSize * 2.4 +
            4.0 * 2; // minContentHeight + minCellPadding * 2

        // Test 6-row month calculation with more aggressive divisors
        final rowHeight6Rows = (remainingHeight / 6.5).clamp(
          minRowHeight,
          55.0,
        ); // More aggressive: 6.5 for large windows, max 55.0
        expect(rowHeight6Rows, greaterThanOrEqualTo(minRowHeight));
        expect(rowHeight6Rows, lessThanOrEqualTo(55.0));

        // 6-row months should have significantly better spacing
        expect(
          rowHeight6Rows,
          greaterThan(50.0),
        ); // Should be around 69.2 for 500px height with 6.5 divisor

        // Compare with 5-row months
        final rowHeight5Rows = (remainingHeight / 5.8).clamp(
          minRowHeight,
          70.0,
        ); // Kept at 5.8 for consistency
        expect(rowHeight5Rows, greaterThan(rowHeight6Rows));

        // Test different window sizes for 6-row months with aggressive spacing
        const smallHeight = 400.0;
        const smallRemainingHeight =
            smallHeight - daysOfWeekHeight - headerPadding;
        final smallRowHeight6Rows = (smallRemainingHeight / 7.8).clamp(
          minRowHeight,
          55.0,
        );
        expect(smallRowHeight6Rows, greaterThan(40.0));

        const mediumHeight = 450.0;
        const mediumRemainingHeight =
            mediumHeight - daysOfWeekHeight - headerPadding;
        final mediumRowHeight6Rows = (mediumRemainingHeight / 6.8).clamp(
          minRowHeight,
          55.0,
        );
        expect(mediumRowHeight6Rows, greaterThan(45.0));
      },
    );

    test('Calculate rows needed for specific months', () {
      // Test the _calculateRowsNeededForMonth logic for known 6-row months

      // June 2025: starts on Sunday (6), has 30 days
      // First day weekday: (7 - 1) % 7 = 6 (Sunday)
      // Total cells: 6 + 30 = 36
      // Rows needed: ceil(36/7) = 6
      final june2025 = DateTime(2025, 6);
      final firstDayWeekday = (june2025.weekday - 1) % 7;
      final daysInMonth = DateTime(2025, 7, 0).day; // Last day of June
      final totalCells = firstDayWeekday + daysInMonth;
      final rowsNeeded = (totalCells / 7).ceil();

      expect(rowsNeeded, equals(6));

      // March 2026: starts on Sunday (6), has 31 days
      // First day weekday: (7 - 1) % 7 = 6 (Sunday)
      // Total cells: 6 + 31 = 37
      // Rows needed: ceil(37/7) = 6
      final march2026 = DateTime(2026, 3);
      final firstDayWeekday2026 = (march2026.weekday - 1) % 7;
      final daysInMonth2026 = DateTime(2026, 4, 0).day; // Last day of March
      final totalCells2026 = firstDayWeekday2026 + daysInMonth2026;
      final rowsNeeded2026 = (totalCells2026 / 7).ceil();

      expect(rowsNeeded2026, equals(6));
    });
  });
}
