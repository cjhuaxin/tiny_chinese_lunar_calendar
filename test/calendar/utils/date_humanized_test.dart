import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/utils/date_humanized.dart';

void main() {
  group('DateHumanized', () {
    final referenceDate = DateTime(2024, 1, 15); // Monday, January 15, 2024

    test('should return "今天" for today', () {
      final result = DateHumanized.humanize(
        referenceDate,
        referenceDate: referenceDate,
      );
      expect(result, '今天');
    });

    test('should return "昨天" for yesterday', () {
      final yesterday = DateTime(2024, 1, 14);
      final result = DateHumanized.humanize(
        yesterday,
        referenceDate: referenceDate,
      );
      expect(result, '昨天');
    });

    test('should return "明天" for tomorrow', () {
      final tomorrow = DateTime(2024, 1, 16);
      final result = DateHumanized.humanize(
        tomorrow,
        referenceDate: referenceDate,
      );
      expect(result, '明天');
    });

    test('should return specific days for dates less than one month', () {
      // 5 days ago
      final fiveDaysAgo = DateTime(2024, 1, 10);
      final result1 = DateHumanized.humanize(
        fiveDaysAgo,
        referenceDate: referenceDate,
      );
      expect(result1, '5天前');

      // 10 days later
      final tenDaysLater = DateTime(2024, 1, 25);
      final result2 = DateHumanized.humanize(
        tenDaysLater,
        referenceDate: referenceDate,
      );
      expect(result2, '10天后');
    });

    test(
      'should return months for dates more than one month but less than one year',
      () {
        // 2 months ago (exact)
        final twoMonthsAgo = DateTime(2023, 11, 15);
        final result1 = DateHumanized.humanize(
          twoMonthsAgo,
          referenceDate: referenceDate,
        );
        expect(result1, '2月前');

        // 3 months and 5 days later
        final threeMonthsFiveDaysLater = DateTime(2024, 4, 20);
        final result2 = DateHumanized.humanize(
          threeMonthsFiveDaysLater,
          referenceDate: referenceDate,
        );
        expect(result2, '3月 5天后');
      },
    );

    test('should return years for dates more than one year', () {
      // 1 year ago (exact)
      final oneYearAgo = DateTime(2023, 1, 15);
      final result1 = DateHumanized.humanize(
        oneYearAgo,
        referenceDate: referenceDate,
      );
      expect(result1, '1年前');

      // 2 years and 3 months later
      final twoYearsThreeMonthsLater = DateTime(2026, 4, 15);
      final result2 = DateHumanized.humanize(
        twoYearsThreeMonthsLater,
        referenceDate: referenceDate,
      );
      expect(result2, '2年 3月后');

      // 1 year, 2 months, and 10 days ago
      final complexPastDate = DateTime(2022, 11, 5);
      final result3 = DateHumanized.humanize(
        complexPastDate,
        referenceDate: referenceDate,
      );
      expect(result3, '1年 2月 10天前');
    });

    test('should handle edge cases around month boundaries', () {
      // Test end of month to beginning of next month
      final endOfMonth = DateTime(2024, 1, 31);
      final beginningOfNextMonth = DateTime(2024, 2, 1);

      final result1 = DateHumanized.humanize(
        endOfMonth,
        referenceDate: referenceDate,
      );
      expect(result1, '16天后');

      final result2 = DateHumanized.humanize(
        beginningOfNextMonth,
        referenceDate: referenceDate,
      );
      expect(result2, '17天后');
    });

    test('should handle leap year correctly', () {
      final leapYearRef = DateTime(2024, 2, 29); // Leap year
      final oneYearLater = DateTime(2025, 2, 28);

      final result = DateHumanized.humanize(
        oneYearLater,
        referenceDate: leapYearRef,
      );
      expect(result, '11月 30天后');
    });

    test('should use current date when no reference date is provided', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final result = DateHumanized.humanize(yesterday);
      expect(result, '昨天');
    });
  });
}
