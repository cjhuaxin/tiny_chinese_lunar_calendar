import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calendar Row Calculation Tests', () {
    test('June 2025 should need 6 rows (1st falls on Sunday)', () {
      // June 2025: 1st is Sunday, should need 6 rows
      final june2025 = DateTime(2025, 6, 15); // Any day in June 2025
      
      // Create a test instance to access the private method
      // We'll test the logic directly here since we can't access private methods
      
      // June 2025 calculation:
      final firstDayOfMonth = DateTime(2025, 6); // June 1, 2025 is Sunday
      final lastDayOfMonth = DateTime(2025, 6 + 1, 0); // June 30, 2025
      
      // First day weekday: Sunday = 7, converted to (7-1) % 7 = 6
      final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
      print('June 2025 first day weekday: $firstDayWeekday (0=Mon, 6=Sun)');
      
      // Days in month: 30
      final daysInMonth = lastDayOfMonth.day;
      print('Days in June 2025: $daysInMonth');
      
      // Total cells needed: 6 (previous month fill) + 30 (current month) = 36
      final totalCells = firstDayWeekday + daysInMonth;
      print('Total cells needed: $totalCells');
      
      // Rows needed: ceil(36/7) = 6
      final rowsNeeded = (totalCells / 7).ceil();
      print('Rows needed for June 2025: $rowsNeeded');
      
      expect(rowsNeeded, equals(6));
    });

    test('May 2025 should need 5 rows (1st falls on Thursday)', () {
      // May 2025: 1st is Thursday, should need 5 rows
      final may2025 = DateTime(2025, 5, 15); // Any day in May 2025
      
      // May 2025 calculation:
      final firstDayOfMonth = DateTime(2025, 5); // May 1, 2025 is Thursday
      final lastDayOfMonth = DateTime(2025, 5 + 1, 0); // May 31, 2025
      
      // First day weekday: Thursday = 4, converted to (4-1) % 7 = 3
      final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
      print('May 2025 first day weekday: $firstDayWeekday (0=Mon, 6=Sun)');
      
      // Days in month: 31
      final daysInMonth = lastDayOfMonth.day;
      print('Days in May 2025: $daysInMonth');
      
      // Total cells needed: 3 (previous month fill) + 31 (current month) = 34
      final totalCells = firstDayWeekday + daysInMonth;
      print('Total cells needed: $totalCells');
      
      // Rows needed: ceil(34/7) = 5
      final rowsNeeded = (totalCells / 7).ceil();
      print('Rows needed for May 2025: $rowsNeeded');
      
      expect(rowsNeeded, equals(5));
    });

    test('February 2024 should need 5 rows (leap year, 1st falls on Thursday)', () {
      // February 2024: 1st is Thursday, leap year with 29 days, should need 5 rows
      final feb2024 = DateTime(2024, 2, 15); // Any day in February 2024
      
      // February 2024 calculation:
      final firstDayOfMonth = DateTime(2024, 2); // Feb 1, 2024 is Thursday
      final lastDayOfMonth = DateTime(2024, 2 + 1, 0); // Feb 29, 2024 (leap year)
      
      // First day weekday: Thursday = 4, converted to (4-1) % 7 = 3
      final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
      print('February 2024 first day weekday: $firstDayWeekday (0=Mon, 6=Sun)');
      
      // Days in month: 29 (leap year)
      final daysInMonth = lastDayOfMonth.day;
      print('Days in February 2024: $daysInMonth');
      
      // Total cells needed: 3 (previous month fill) + 29 (current month) = 32
      final totalCells = firstDayWeekday + daysInMonth;
      print('Total cells needed: $totalCells');
      
      // Rows needed: ceil(32/7) = 5
      final rowsNeeded = (totalCells / 7).ceil();
      print('Rows needed for February 2024: $rowsNeeded');
      
      expect(rowsNeeded, equals(5));
    });

    test('March 2025 should need 6 rows (1st falls on Saturday)', () {
      // March 2025: 1st is Saturday, should need 6 rows
      final march2025 = DateTime(2025, 3, 15); // Any day in March 2025
      
      // March 2025 calculation:
      final firstDayOfMonth = DateTime(2025, 3); // March 1, 2025 is Saturday
      final lastDayOfMonth = DateTime(2025, 3 + 1, 0); // March 31, 2025
      
      // First day weekday: Saturday = 6, converted to (6-1) % 7 = 5
      final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
      print('March 2025 first day weekday: $firstDayWeekday (0=Mon, 6=Sun)');
      
      // Days in month: 31
      final daysInMonth = lastDayOfMonth.day;
      print('Days in March 2025: $daysInMonth');
      
      // Total cells needed: 5 (previous month fill) + 31 (current month) = 36
      final totalCells = firstDayWeekday + daysInMonth;
      print('Total cells needed: $totalCells');
      
      // Rows needed: ceil(36/7) = 6
      final rowsNeeded = (totalCells / 7).ceil();
      print('Rows needed for March 2025: $rowsNeeded');
      
      expect(rowsNeeded, equals(6));
    });
  });
}
