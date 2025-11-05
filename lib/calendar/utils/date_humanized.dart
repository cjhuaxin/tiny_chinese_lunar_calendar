class DateHumanized {
  /// Returns a humanized date string in Chinese based on the difference between
  /// the selected date and today's date.
  ///
  /// Rules:
  /// 1. Yesterday: "昨天"
  /// 2. Tomorrow: "明天"
  /// 3. Less than one month: specific number of days
  /// 4. More than one month and less than one year: "%d月" or "%d月 %d天"
  /// 5. More than one year: "%d年", "%d年 %d月" or "%d年 %d月 %d天"
  static String humanize(DateTime selectedDate, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final difference = selected.difference(today).inDays;

    // Handle yesterday and tomorrow
    if (difference == -1) {
      return '昨天';
    } else if (difference == 1) {
      return '明天';
    }

    // Calculate the actual time difference in years, months, and days
    final isInPast = selected.isBefore(today);
    final startDate = isInPast ? selected : today;
    final endDate = isInPast ? today : selected;

    var years = endDate.year - startDate.year;
    var months = endDate.month - startDate.month;
    var days = endDate.day - startDate.day;

    // Adjust for negative days
    if (days < 0) {
      months--;
      final previousMonth = DateTime(endDate.year, endDate.month, 0);
      days += previousMonth.day;
    }

    // Adjust for negative months
    if (months < 0) {
      years--;
      months += 12;
    }

    final totalDays = difference.abs();

    // Less than one month (approximately 30 days)
    if (totalDays < 30) {
      if (totalDays == 0) {
        return '今天';
      }
      return '${totalDays}天${appendSuffix(isInPast)}';
    }

    // More than one year
    if (years > 0) {
      if (months == 0 && days == 0) {
        return '${years}年${appendSuffix(isInPast)}';
      } else if (days == 0) {
        return '${years}年${months}月${appendSuffix(isInPast)}';
      } else {
        return '${years}年${months}月${days}天${appendSuffix(isInPast)}';
      }
    }

    // More than one month but less than one year
    if (days == 0) {
      return '${months}月${appendSuffix(isInPast)}';
    } else {
      return '${months}月${days}天${appendSuffix(isInPast)}';
    }
  }

  static String appendSuffix(bool isInPast) {
    if (isInPast) {
      return ' 前';
    }

    return ' 后';
  }
}
