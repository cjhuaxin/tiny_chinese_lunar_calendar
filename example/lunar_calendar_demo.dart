import 'package:tiny_chinese_lunar_calendar/calendar/utils/lunar_calendar.dart';

void main() {
  print('=== 农历转换演示 ===\n');

  // 测试一些重要日期
  final testDates = [
    DateTime(2025, 1, 1), // 元旦
    DateTime(2025, 1, 29), // 可能的春节
    DateTime(2025, 6, 1), // 儿童节
    DateTime(2025, 10, 1), // 国庆节
    DateTime(2025, 12, 25), // 圣诞节
  ];

  for (final date in testDates) {
    final lunarDate = LunarCalendar.solarToLunar(date);
    print('公历: ${date.year}年${date.month}月${date.day}日');
    print('农历: ${lunarDate.fullText}');
    print('生肖: ${LunarCalendar.getZodiacAnimal(lunarDate.year)}年');
    print('干支: ${LunarCalendar.getGanZhiYear(lunarDate.year)}');
    print('---');
  }

  print('\n=== 农历日期格式化测试 ===');
  for (int i = 1; i <= 30; i++) {
    if (i <= 10 || i % 5 == 0 || i > 25) {
      print('农历${i}日: ${LunarCalendar.formatLunarDay(i)}');
    }
  }

  print('\n=== 农历月份格式化测试 ===');
  for (int i = 1; i <= 12; i++) {
    print('农历${i}月: ${LunarCalendar.formatLunarMonth(i)}');
  }
}
