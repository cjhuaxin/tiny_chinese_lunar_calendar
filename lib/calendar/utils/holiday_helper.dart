import 'package:lunar/lunar.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/services/chinese_holiday_service.dart';

/// Helper class for working with Chinese holidays
class HolidayHelper {
  static final ChineseHolidayService _holidayService = ChineseHolidayService();

  /// Get holiday information for a specific date
  /// Returns null if no holiday data is available
  static Holiday? getHolidayForDate(DateTime date) {
    final dateString =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return HolidayUtil.getHoliday(dateString);
  }

  /// Check if a date has holiday information (from new API or fallback)
  static bool hasHolidayInfo(DateTime date) {
    final dateString = _formatDateString(date);

    // Check new API data first
    if (_holidayService.isHoliday(dateString) ||
        _holidayService.isWorkday(dateString)) {
      return true;
    }

    // Fallback to original implementation
    return getHolidayForDate(date) != null;
  }

  /// Check if a date is a work day during holiday period
  /// Returns null if no holiday data is available
  static bool? isWorkDay(DateTime date) {
    final dateString = _formatDateString(date);

    // Check new API data first
    if (_holidayService.isWorkday(dateString)) {
      return true; // 班 (work day)
    }

    if (_holidayService.isHoliday(dateString)) {
      return false; // 休 (holiday)
    }

    // Fallback to original implementation
    final holiday = getHolidayForDate(date);
    return holiday?.isWork();
  }

  /// Initialize the holiday service (call this early in app lifecycle)
  static Future<void> initialize() async {
    await _holidayService.getHolidayData();
  }

  /// Format date to string in YYYY-MM-DD format
  static String _formatDateString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Get holiday information string for a date
  static String? getHolidayInfoString(DateTime date) {
    final dateString = _formatDateString(date);
    return _holidayService.getHolidayInfo(dateString);
  }

  /// Force refresh holiday data from API
  static Future<void> refreshHolidayData() async {
    await _holidayService.forceRefresh();
  }
}
