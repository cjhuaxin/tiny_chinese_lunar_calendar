import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Outside Date Behavior Examples', () {
    test('January 2024 - last day is Wednesday', () {
      // 2024年1月31日是星期三
      final lastDayOfMonth = DateTime(2024, 1, 31);
      print('2024年1月31日是星期${lastDayOfMonth.weekday}'); // 星期三 = 3
      
      // 计算最后一天是星期几（0=周一, 6=周日）
      final lastDayWeekday = (lastDayOfMonth.weekday - 1) % 7; // 星期三 = 2
      print('转换后的星期数: $lastDayWeekday (0=周一, 6=周日)');
      
      // 计算需要填充的天数
      final daysToFill = 6 - lastDayWeekday; // 6 - 2 = 4天
      print('需要填充的下个月日期数: $daysToFill');
      print('应该显示: 2月1日 到 2月$daysToFill日');
      
      expect(daysToFill, equals(4));
    });

    test('March 2024 - last day is Sunday', () {
      // 2024年3月31日是星期日
      final lastDayOfMonth = DateTime(2024, 3, 31);
      print('2024年3月31日是星期${lastDayOfMonth.weekday}'); // 星期日 = 7
      
      // 计算最后一天是星期几（0=周一, 6=周日）
      final lastDayWeekday = (lastDayOfMonth.weekday - 1) % 7; // 星期日 = 6
      print('转换后的星期数: $lastDayWeekday (0=周一, 6=周日)');
      
      // 计算需要填充的天数
      final daysToFill = 6 - lastDayWeekday; // 6 - 6 = 0天
      print('需要填充的下个月日期数: $daysToFill');
      print('应该显示: 无下个月日期');
      
      expect(daysToFill, equals(0));
    });

    test('February 2024 - last day is Thursday', () {
      // 2024年2月29日是星期四（闰年）
      final lastDayOfMonth = DateTime(2024, 2, 29);
      print('2024年2月29日是星期${lastDayOfMonth.weekday}'); // 星期四 = 4
      
      // 计算最后一天是星期几（0=周一, 6=周日）
      final lastDayWeekday = (lastDayOfMonth.weekday - 1) % 7; // 星期四 = 3
      print('转换后的星期数: $lastDayWeekday (0=周一, 6=周日)');
      
      // 计算需要填充的天数
      final daysToFill = 6 - lastDayWeekday; // 6 - 3 = 3天
      print('需要填充的下个月日期数: $daysToFill');
      print('应该显示: 3月1日 到 3月$daysToFill日');
      
      expect(daysToFill, equals(3));
    });

    test('December 2024 - last day is Tuesday', () {
      // 2024年12月31日是星期二
      final lastDayOfMonth = DateTime(2024, 12, 31);
      print('2024年12月31日是星期${lastDayOfMonth.weekday}'); // 星期二 = 2
      
      // 计算最后一天是星期几（0=周一, 6=周日）
      final lastDayWeekday = (lastDayOfMonth.weekday - 1) % 7; // 星期二 = 1
      print('转换后的星期数: $lastDayWeekday (0=周一, 6=周日)');
      
      // 计算需要填充的天数
      final daysToFill = 6 - lastDayWeekday; // 6 - 1 = 5天
      print('需要填充的下个月日期数: $daysToFill');
      print('应该显示: 2025年1月1日 到 1月$daysToFill日');
      
      expect(daysToFill, equals(5));
    });
  });
}
