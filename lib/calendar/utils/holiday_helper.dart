import 'package:lunar/lunar.dart';

/// Helper class for working with Chinese holidays
class HolidayHelper {
  /// Get holiday information for a specific date
  /// Returns null if no holiday data is available
  static Holiday? getHolidayForDate(DateTime date) {
    final dateString = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    
    return HolidayUtil.getHoliday(dateString);
  }
  
  /// Check if a date has holiday information
  static bool hasHolidayInfo(DateTime date) {
    return getHolidayForDate(date) != null;
  }
  
  /// Check if a date is a work day during holiday period
  /// Returns null if no holiday data is available
  static bool? isWorkDay(DateTime date) {
    final holiday = getHolidayForDate(date);
    return holiday?.isWork();
  }
}
