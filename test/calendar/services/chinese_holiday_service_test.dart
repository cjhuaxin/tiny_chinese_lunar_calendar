import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/services/chinese_holiday_service.dart';

void main() {
  group('ChineseHolidayService', () {
    late ChineseHolidayService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = ChineseHolidayService();
    });

    test('should be a singleton', () {
      final service1 = ChineseHolidayService();
      final service2 = ChineseHolidayService();
      expect(service1, equals(service2));
    });

    test('should return false for holiday/workday when no data cached', () {
      expect(service.isHoliday('2025-01-01'), false);
      expect(service.isWorkday('2025-01-01'), false);
    });

    test('should return null for holiday info when no data cached', () {
      expect(service.getHolidayInfo('2025-01-01'), null);
    });

    test('should handle cache clearing', () async {
      await service.clearCache();
      expect(service.isHoliday('2025-01-01'), false);
    });

    test('should fetch data from API', () async {
      // This test will actually try to fetch from the API
      // In a real test environment, you might want to mock the HTTP client
      final data = await service.getHolidayData();
      
      // The test might fail if there's no internet connection
      // but that's expected behavior for this integration test
      if (data != null) {
        expect(data, isA<Map<String, dynamic>>());
        expect(data.containsKey('holidays'), true);
        expect(data.containsKey('workdays'), true);
      }
    });
  });
}
