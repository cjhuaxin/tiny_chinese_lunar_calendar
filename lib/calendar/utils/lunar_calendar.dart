/// 农历转换工具类
/// 提供公历到农历的转换功能和中文格式化
class LunarCalendar {
  // 农历数据：每年的农历月份天数信息（1900-2100年）
  // 这是一个简化的实现，实际应用中可能需要更完整的数据
  static const List<int> _lunarInfo = [
    0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2,
    0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977,
    0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970,
    0x06566, 0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950,
    0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557,
    0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5b0, 0x14573, 0x052b0, 0x0a9a8, 0x0e950, 0x06aa0,
    0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0,
    0x096d0, 0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b6a0, 0x195a6,
    0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46, 0x0ab60, 0x09570,
    0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58, 0x055c0, 0x0ab60, 0x096d5, 0x092e0,
    0x0c960, 0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5,
    0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930,
    0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65, 0x0d530,
    0x05aa0, 0x076a3, 0x096d0, 0x04bd7, 0x04ad0, 0x0a4d0, 0x1d0b6, 0x0d250, 0x0d520, 0x0dd45,
    0x0b5a0, 0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0,
    0x14b63, 0x09370, 0x049f8, 0x04970, 0x064b0, 0x168a6, 0x0ea50, 0x06b20, 0x1a6c4, 0x0aae0,
    0x0a2e0, 0x0d2e3, 0x0c960, 0x0d557, 0x0d4a0, 0x0da50, 0x05d55, 0x056a0, 0x0a6d0, 0x055d4,
    0x052d0, 0x0a9b8, 0x0a950, 0x0b4a0, 0x0b6a6, 0x0ad50, 0x055a0, 0x0aba4, 0x0a5b0, 0x052b0,
    0x0b273, 0x06930, 0x07337, 0x06aa0, 0x0ad50, 0x14b55, 0x04b60, 0x0a570, 0x054e4, 0x0d160,
    0x0e968, 0x0d520, 0x0daa0, 0x16aa6, 0x056d0, 0x04ae0, 0x0a9d4, 0x0a2d0, 0x0d150, 0x0f252,
    0x0d520, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977, 0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40,
  ];

  // 农历月份名称
  static const List<String> _lunarMonths = [
    '正月', '二月', '三月', '四月', '五月', '六月',
    '七月', '八月', '九月', '十月', '冬月', '腊月'
  ];

  // 农历日期名称
  static const List<String> _lunarDays = [
    '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
    '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
    '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
  ];

  // 天干
  static const List<String> _heavenlyStems = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'
  ];

  // 地支
  static const List<String> _earthlyBranches = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'
  ];

  // 生肖
  static const List<String> _zodiacAnimals = [
    '鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'
  ];

  /// 将公历日期转换为农历信息
  static LunarDate solarToLunar(DateTime solarDate) {
    // 这是一个简化的实现
    // 实际的农历转换算法非常复杂，这里提供一个基本的近似计算
    
    final year = solarDate.year;
    final month = solarDate.month;
    final day = solarDate.day;
    
    // 基准日期：1900年1月31日为农历1900年正月初一
    final baseDate = DateTime(1900, 1, 31);
    final daysDiff = solarDate.difference(baseDate).inDays;
    
    // 简化计算：这里使用一个近似的方法
    // 实际应用中应该使用更精确的农历算法
    int lunarYear = 1900;
    int remainingDays = daysDiff;
    
    // 计算农历年份
    while (remainingDays > 0) {
      final yearDays = _getLunarYearDays(lunarYear);
      if (remainingDays < yearDays) break;
      remainingDays -= yearDays;
      lunarYear++;
    }
    
    // 计算农历月份和日期
    int lunarMonth = 1;
    while (remainingDays > 0) {
      final monthDays = _getLunarMonthDays(lunarYear, lunarMonth);
      if (remainingDays < monthDays) break;
      remainingDays -= monthDays;
      lunarMonth++;
    }
    
    final lunarDay = remainingDays + 1;
    
    return LunarDate(
      year: lunarYear,
      month: lunarMonth,
      day: lunarDay,
      isLeapMonth: false, // 简化实现，不处理闰月
    );
  }

  /// 获取农历年的总天数
  static int _getLunarYearDays(int year) {
    if (year < 1900 || year > 2100) return 354; // 默认值
    
    final info = _lunarInfo[year - 1900];
    int days = 0;
    
    // 计算12个月的天数
    for (int i = 0x8000; i > 0x8; i >>= 1) {
      days += (info & i) != 0 ? 30 : 29;
    }
    
    // 如果有闰月，加上闰月的天数
    if (_getLeapMonth(year) != 0) {
      days += _getLeapMonthDays(year);
    }
    
    return days;
  }

  /// 获取农历月的天数
  static int _getLunarMonthDays(int year, int month) {
    if (year < 1900 || year > 2100) return 29; // 默认值
    
    final info = _lunarInfo[year - 1900];
    return (info & (0x10000 >> month)) != 0 ? 30 : 29;
  }

  /// 获取闰月月份（0表示无闰月）
  static int _getLeapMonth(int year) {
    if (year < 1900 || year > 2100) return 0;
    return _lunarInfo[year - 1900] & 0xf;
  }

  /// 获取闰月天数
  static int _getLeapMonthDays(int year) {
    if (_getLeapMonth(year) == 0) return 0;
    final info = _lunarInfo[year - 1900];
    return (info & 0x10000) != 0 ? 30 : 29;
  }

  /// 格式化农历日期为中文
  static String formatLunarDay(int day) {
    if (day < 1 || day > 30) return '';
    return _lunarDays[day - 1];
  }

  /// 格式化农历月份为中文
  static String formatLunarMonth(int month) {
    if (month < 1 || month > 12) return '';
    return _lunarMonths[month - 1];
  }

  /// 获取生肖
  static String getZodiacAnimal(int year) {
    return _zodiacAnimals[(year - 4) % 12];
  }

  /// 获取天干地支年份
  static String getGanZhiYear(int year) {
    final ganIndex = (year - 4) % 10;
    final zhiIndex = (year - 4) % 12;
    return '${_heavenlyStems[ganIndex]}${_earthlyBranches[zhiIndex]}';
  }
}

/// 农历日期数据类
class LunarDate {
  final int year;
  final int month;
  final int day;
  final bool isLeapMonth;

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    this.isLeapMonth = false,
  });

  /// 获取农历日期的中文表示（只显示日）
  String get dayText => LunarCalendar.formatLunarDay(day);

  /// 获取完整的农历日期字符串
  String get fullText {
    final monthText = LunarCalendar.formatLunarMonth(month);
    final dayText = LunarCalendar.formatLunarDay(day);
    final leapPrefix = isLeapMonth ? '闰' : '';
    return '$leapPrefix$monthText$dayText';
  }

  /// 获取农历年份信息
  String get yearText {
    final ganZhi = LunarCalendar.getGanZhiYear(year);
    final zodiac = LunarCalendar.getZodiacAnimal(year);
    return '$ganZhi年（$zodiac年）';
  }

  @override
  String toString() => fullText;
}
