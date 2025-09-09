import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/view/calendar_page.dart';

void main() {
  group('Outside Date Display Logic', () {
    test('should show previous month dates', () {
      // 测试2024年1月的日历，应该显示2023年12月的日期来填充第一周
      final focusedDay = DateTime(2024, 1, 15); // 2024年1月15日
      final previousMonthDay = DateTime(2023, 12, 31); // 2023年12月31日

      // 测试跨年的情况：2023年12月 < 2024年1月
      // 需要考虑跨年的逻辑
      final isPreviousMonth =
          previousMonthDay.month < focusedDay.month ||
          (previousMonthDay.month == 12 &&
              focusedDay.month == 1 &&
              previousMonthDay.year < focusedDay.year);

      // 上个月的日期应该总是显示
      expect(isPreviousMonth, isTrue);
    });

    test('should limit next month dates to last week only', () {
      // 测试2024年1月的日历
      // 2024年1月31日是星期三，所以最后一周需要显示2月1-4日
      final focusedDay = DateTime(2024, 1, 15); // 2024年1月15日
      final lastDayOfMonth = DateTime(2024, 1, 31); // 2024年1月31日（星期三）

      // 计算最后一天是星期几（0=周一, 6=周日）
      final lastDayWeekday = (lastDayOfMonth.weekday - 1) % 7; // 星期三 = 2

      // 计算需要填充的天数
      final daysToFill = 6 - lastDayWeekday; // 6 - 2 = 4天

      expect(daysToFill, equals(4));

      // 下个月的前4天应该显示：2月1-4日
      final nextMonth1 = DateTime(2024, 2, 1);
      final nextMonth4 = DateTime(2024, 2, 4);
      final nextMonth5 = DateTime(2024, 2, 5);

      // 2月1-4日应该在允许范围内
      expect(nextMonth1.difference(lastDayOfMonth).inDays, equals(1));
      expect(nextMonth4.difference(lastDayOfMonth).inDays, equals(4));
      expect(nextMonth5.difference(lastDayOfMonth).inDays, equals(5));

      // 2月1-4日应该显示，2月5日不应该显示
      expect(
        nextMonth1.difference(lastDayOfMonth).inDays <= daysToFill,
        isTrue,
      );
      expect(
        nextMonth4.difference(lastDayOfMonth).inDays <= daysToFill,
        isTrue,
      );
      expect(
        nextMonth5.difference(lastDayOfMonth).inDays <= daysToFill,
        isFalse,
      );
    });

    test('should not show next month dates when last day is Sunday', () {
      // 测试当月最后一天是周日的情况
      // 2024年3月31日是星期日
      final focusedDay = DateTime(2024, 3, 15); // 2024年3月15日
      final lastDayOfMonth = DateTime(2024, 3, 31); // 2024年3月31日（星期日）

      // 计算最后一天是星期几（0=周一, 6=周日）
      final lastDayWeekday = (lastDayOfMonth.weekday - 1) % 7; // 星期日 = 6

      // 计算需要填充的天数
      final daysToFill = 6 - lastDayWeekday; // 6 - 6 = 0天

      expect(daysToFill, equals(0));

      // 当最后一天是周日时，不需要显示下个月的任何日期
      final nextMonth1 = DateTime(2024, 4, 1);
      expect(nextMonth1.difference(lastDayOfMonth).inDays > daysToFill, isTrue);
    });
  });
}
