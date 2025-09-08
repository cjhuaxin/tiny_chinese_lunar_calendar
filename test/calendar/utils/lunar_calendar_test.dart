import 'package:ccalendar/calendar/utils/lunar_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LunarCalendar', () {
    test('should convert solar date to lunar date', () {
      // 测试2025年1月1日
      final solarDate = DateTime(2025, 1, 1);
      final lunarDate = LunarCalendar.solarToLunar(solarDate);
      
      // 验证返回的农历日期不为空
      expect(lunarDate, isNotNull);
      expect(lunarDate.year, greaterThan(0));
      expect(lunarDate.month, greaterThan(0));
      expect(lunarDate.day, greaterThan(0));
      
      // 验证农历日期在合理范围内
      expect(lunarDate.month, lessThanOrEqualTo(12));
      expect(lunarDate.day, lessThanOrEqualTo(30));
    });

    test('should format lunar day correctly', () {
      expect(LunarCalendar.formatLunarDay(1), equals('初一'));
      expect(LunarCalendar.formatLunarDay(2), equals('初二'));
      expect(LunarCalendar.formatLunarDay(10), equals('初十'));
      expect(LunarCalendar.formatLunarDay(15), equals('十五'));
      expect(LunarCalendar.formatLunarDay(21), equals('廿一'));
      expect(LunarCalendar.formatLunarDay(30), equals('三十'));
    });

    test('should format lunar month correctly', () {
      expect(LunarCalendar.formatLunarMonth(1), equals('正月'));
      expect(LunarCalendar.formatLunarMonth(2), equals('二月'));
      expect(LunarCalendar.formatLunarMonth(11), equals('冬月'));
      expect(LunarCalendar.formatLunarMonth(12), equals('腊月'));
    });

    test('should get zodiac animal correctly', () {
      expect(LunarCalendar.getZodiacAnimal(2025), equals('蛇'));
      expect(LunarCalendar.getZodiacAnimal(2024), equals('龙'));
      expect(LunarCalendar.getZodiacAnimal(2023), equals('兔'));
    });

    test('should get gan zhi year correctly', () {
      final ganZhi2025 = LunarCalendar.getGanZhiYear(2025);
      expect(ganZhi2025, isNotEmpty);
      expect(ganZhi2025.length, equals(2));
    });

    test('LunarDate should provide correct text representations', () {
      const lunarDate = LunarDate(
        year: 2025,
        month: 1,
        day: 2,
      );
      
      expect(lunarDate.dayText, equals('初二'));
      expect(lunarDate.fullText, equals('正月初二'));
      expect(lunarDate.yearText, contains('蛇年'));
    });

    test('should handle different dates throughout the year', () {
      final testDates = [
        DateTime(2025, 1, 1),
        DateTime(2025, 6, 15),
        DateTime(2025, 12, 31),
      ];
      
      for (final date in testDates) {
        final lunarDate = LunarCalendar.solarToLunar(date);
        expect(lunarDate.dayText, isNotEmpty);
        expect(lunarDate.fullText, isNotEmpty);
      }
    });
  });
}
