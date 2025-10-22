import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tiny_chinese_lunar_calendar/app/theme/app_theme.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/utils/holiday_helper.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/widgets/holiday_tag.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/widgets/today_icon.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/widgets/year_month_picker_dialog.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/l10n.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key, this.onLanguageChanged});

  final void Function(Locale)? onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return CalendarView(onLanguageChanged: onLanguageChanged);
  }
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year - 100);
final kLastDay = DateTime(kToday.year + 100, 12, 31);

class CalendarView extends StatefulWidget {
  const CalendarView({
    super.key,
    this.onLanguageChanged,
    this.initialFocusedDay,
  });

  final void Function(Locale)? onLanguageChanged;
  final DateTime? initialFocusedDay;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime? _selectedDay;
  late DateTime _focusedDay;
  bool _sundayFirst = false;
  static const MethodChannel _channel = MethodChannel('calendar_settings');

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
    _loadSettings();
    _setupMethodChannel();
    _initializeHolidayService();
  }

  void _loadSettings() {
    // Load the Sunday first setting from native preferences
    // This will be synced with the native UserDefaults
    _channel
        .invokeMethod('getSettings')
        .then((result) {
          if (result != null && result is Map) {
            setState(() {
              _sundayFirst = (result['sundayFirst'] as bool?) ?? false;
            });
          }
        })
        .catchError((Object error) {
          // If method channel fails, use default value
          debugPrint('Failed to load settings: $error');
        });
  }

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'settingsChanged') {
        final arguments = call.arguments as Map<dynamic, dynamic>;
        setState(() {
          _sundayFirst = (arguments['sundayFirst'] as bool?) ?? false;
        });
      }
    });
  }

  void _initializeHolidayService() {
    // Initialize holiday service in background after Flutter bindings are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HolidayHelper.initialize().catchError((Object error) {
        debugPrint('Failed to initialize holiday service: $error');
      });
    });
  }

  /// Show unified year-month picker dialog
  Future<void> _showYearMonthPicker() async {
    final selectedDate = await showYearMonthPicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: kFirstDay,
      lastDate: kLastDay,
    );

    if (selectedDate != null) {
      // After closing the picker, automatically select the first day of the
      // chosen month to improve UX.
      setState(() {
        _focusedDay = selectedDate;
        _selectedDay = DateTime(selectedDate.year, selectedDate.month);
      });
    }
  }

  /// 构建非当月日期单元格，同时显示公历和农历日期
  Widget _buildOutsideDateCell(
    DateTime day,
    bool isSelected,
    bool isToday,
    double cellSize, {
    double? availableRowHeight,
  }) {
    final lunarDate = Lunar.fromDate(day);
    final solarDate = Solar.fromDate(day);
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    // Festival information will be handled in _getLunarTextColor method

    Color? textColor;

    // 非当月日期使用灰色文字，但保持相同的大小和布局
    if (isWeekend) {
      // 周末日期使用红色，但因为是非当月日期，所以使用较淡的红色
      textColor = AppTheme.chineseRed.withValues(alpha: 0.4);
    } else {
      textColor = Colors.grey[400]; // 非当月日期使用灰色
    }

    // 根据单元格大小和可用行高动态计算字体大小，与当月日期保持一致
    // 增大字体大小，提升可读性
    final basePrimaryFontSize = (cellSize * 0.22).clamp(8.0, 15.0);
    final baseSecondaryFontSize = (cellSize * 0.12).clamp(6.0, 10.0);

    // 如果有可用行高信息，进一步限制字体大小
    final primaryFontSize = availableRowHeight != null
        ? basePrimaryFontSize.clamp(
            8.0,
            (availableRowHeight * 0.35).clamp(8.0, 15.0),
          )
        : basePrimaryFontSize;
    final secondaryFontSize = availableRowHeight != null
        ? baseSecondaryFontSize.clamp(
            6.0,
            (availableRowHeight * 0.20).clamp(6.0, 10.0),
          )
        : baseSecondaryFontSize;

    // 在极小的单元格或行高中隐藏农历文本
    // 由于增大了字体和行高，可以放宽显示条件
    final showLunarText =
        cellSize > 28 &&
        (availableRowHeight == null || availableRowHeight > 30) &&
        primaryFontSize >= 8.0; // 确保主字体足够大时才显示农历

    final lunarText = _getLunarText(lunarDate, solarDate);

    // Calculate lunar text color based on content type
    final calculatedLunarTextColor = _getLunarTextColor(
      lunarText,
      lunarDate,
      solarDate,
      defaultColor: Colors.grey[400],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available space more flexibly, don't force aspect ratio
        // if it causes overflow
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              // Main content layer - always visible
              Positioned.fill(
                child: ClipRect(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (cellSize * 0.04).clamp(1.0, 4.0),
                      vertical: (cellSize * 0.04).clamp(1.0, 4.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 公历日期
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: primaryFontSize,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        // 添加垂直间距
                        if (showLunarText)
                          SizedBox(height: (cellSize * 0.01).clamp(0.5, 1.0)),
                        // 农历日期 - 只在单元格足够大时显示
                        if (showLunarText)
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                lunarText,
                                style: TextStyle(
                                  fontSize: secondaryFontSize,
                                  color: calculatedLunarTextColor?.withValues(
                                    alpha: 0.7,
                                  ),
                                  height: 1,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Holiday tag as floating overlay in top-right corner
              if (HolidayHelper.hasHolidayInfo(day))
                Positioned(
                  top: (cellSize * 0.05).clamp(2.0, 6.0),
                  right: (cellSize * 0.1).clamp(2.0, 6.0),
                  child: HolidayTag(
                    isWorkDay: HolidayHelper.isWorkDay(day) ?? false,
                    size: (cellSize * 0.25).clamp(12.0, 18.0),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 构建日期单元格，同时显示公历和农历日期
  Widget _buildDateCell(
    DateTime day,
    bool isSelected,
    bool isToday,
    double cellSize, {
    double? availableRowHeight,
  }) {
    final lunarDate = Lunar.fromDate(day);
    final solarDate = Solar.fromDate(day);
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    // 获取节气和节日信息 - variables will be used in _getLunarTextColor method

    Color? backgroundColor;
    Color? textColor;
    double borderRadius;
    List<BoxShadow>? boxShadow;

    // 根据单元格大小动态计算样式参数，更激进的缩放
    final dynamicBorderRadius = (cellSize * 0.15).clamp(4.0, 16.0);

    // 单元格之间距离(决定了背景的大小) - now used for highlight inset
    final horizontalInset = (cellSize * 0.08).clamp(3.0, 8.0);
    final verticalInset = (cellSize * 0.05).clamp(3.0, 8.0);

    borderRadius = dynamicBorderRadius;
    if (isToday) {
      // Today: use the old selected style (filled background)
      backgroundColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
      // lunarTextColor is now handled after lunarText is calculated
      // Add subtle shadow for better visual hierarchy - more refined
      boxShadow = [
        BoxShadow(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          blurRadius: 2,
        ),
      ];
    } else if (isSelected) {
      // Selected day: light background color instead of border
      backgroundColor = AppTheme.chineseRed.withValues(alpha: 0.1);
      if (isWeekend) {
        textColor = AppTheme.chineseRed;
      } else {
        textColor = null;
      }

      boxShadow = null;
    } else {
      backgroundColor = null;
      if (isWeekend) {
        // 周末日期使用红色
        textColor = AppTheme.chineseRed;
      } else {
        textColor = null;
      }
      // lunarTextColor is now handled after lunarText is calculated
      boxShadow = null;
    }

    // 根据单元格大小和可用行高动态计算字体大小
    // 增大字体大小，提升可读性
    final basePrimaryFontSize = (cellSize * 0.22).clamp(8.0, 15.0);
    final baseSecondaryFontSize = (cellSize * 0.12).clamp(6.0, 10.0);

    // 如果有可用行高信息，进一步限制字体大小
    final primaryFontSize = availableRowHeight != null
        ? basePrimaryFontSize.clamp(
            8.0,
            (availableRowHeight * 0.35).clamp(8.0, 15.0),
          )
        : basePrimaryFontSize;
    final secondaryFontSize = availableRowHeight != null
        ? baseSecondaryFontSize.clamp(
            6.0,
            (availableRowHeight * 0.20).clamp(6.0, 10.0),
          )
        : baseSecondaryFontSize;

    // 在极小的单元格或行高中隐藏农历文本
    // 由于增大了字体和行高，可以放宽显示条件
    final showLunarText =
        cellSize > 28 &&
        (availableRowHeight == null || availableRowHeight > 30) &&
        primaryFontSize >= 8.0; // 确保主字体足够大时才显示农历

    final lunarText = _getLunarText(lunarDate, solarDate);

    // Calculate lunar text color based on content type
    Color? calculatedLunarTextColor;
    if (isToday || (isSelected && isToday)) {
      // For today's cell, use white color to match the date number
      calculatedLunarTextColor = Colors.white;
    } else {
      calculatedLunarTextColor = _getLunarTextColor(
        lunarText,
        lunarDate,
        solarDate,
        defaultColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available space more flexibly, don't force aspect ratio
        // if it causes overflow
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              // Background highlight layer - only visible for today/selected
              if (isToday || isSelected)
                Positioned(
                  left: horizontalInset,
                  right: horizontalInset,
                  top: verticalInset,
                  bottom: verticalInset,
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: boxShadow,
                    ),
                  ),
                ),
              // Main content layer - always visible
              Positioned.fill(
                child: ClipRect(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (cellSize * 0.04).clamp(1.0, 4.0),
                      vertical: (cellSize * 0.04).clamp(1.0, 4.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 公历日期
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: primaryFontSize,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        // 添加垂直间距
                        if (showLunarText)
                          SizedBox(height: (cellSize * 0.01).clamp(0.5, 1.0)),
                        // 农历日期 - 只在单元格足够大时显示
                        if (showLunarText)
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                lunarText,
                                style: TextStyle(
                                  fontSize: secondaryFontSize,
                                  color: calculatedLunarTextColor,
                                  height: 1,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Holiday tag as floating overlay in top-right corner
              if (HolidayHelper.hasHolidayInfo(day))
                Positioned(
                  top: (cellSize * 0.05).clamp(2.0, 6.0),
                  right: (cellSize * 0.1).clamp(2.0, 6.0),
                  child: HolidayTag(
                    isWorkDay: HolidayHelper.isWorkDay(day) ?? false,
                    size: (cellSize * 0.25).clamp(12.0, 18.0),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 计算指定月份需要多少行来显示
  /// 返回值为4、5或6，表示该月份在日历中需要的行数
  int _calculateRowsNeededForMonth(
    DateTime focusedDay,
    bool isSundayFirst,
  ) {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    int firstDayWeekday;
    if (isSundayFirst) {
      // If Sunday is the first day of the week, Sunday is 0, Saturday is 6
      firstDayWeekday = firstDayOfMonth.weekday % 7;
    } else {
      // If Monday is the first day of the week, Monday is 0, Sunday is 6
      firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;
    }

    final daysInMonth = lastDayOfMonth.day;
    final totalCells = firstDayWeekday + daysInMonth;
    final rowsNeeded = (totalCells / 7).ceil();

    return rowsNeeded;
  }

  /// 判断是否应该显示非当月日期
  /// 只显示当月最后一天所在行的下个月日期
  bool _shouldShowOutsideDay(DateTime day, DateTime focusedDay) {
    // 如果是上个月的日期，总是显示（用于填充当月第一周）
    if (day.month < focusedDay.month ||
        (day.month == 12 &&
            focusedDay.month == 1 &&
            day.year < focusedDay.year)) {
      return true;
    }

    // 如果是下个月的日期，只显示当月最后一天所在行的日期
    if (day.month > focusedDay.month ||
        (day.month == 1 &&
            focusedDay.month == 12 &&
            day.year > focusedDay.year)) {
      // 获取当月最后一天
      final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

      // 计算当月最后一天是星期几（0=周一, 6=周日）
      final lastDayWeekday = (lastDayOfMonth.weekday - 1) % 7;

      // 计算当月最后一天所在行还需要多少天来填充到周日
      final daysToFill = 6 - lastDayWeekday;

      // 如果当月最后一天就是周日，则不需要显示下个月的日期
      if (daysToFill == 0) {
        return false;
      }

      // 只显示填充当月最后一天所在行所需的下个月日期
      final daysDifference = day.difference(lastDayOfMonth).inDays;
      return daysDifference > 0 && daysDifference <= daysToFill;
    }

    return false;
  }

  String _getLunarText(Lunar lunarDate, Solar solarDate) {
    // Priority hierarchy:
    // lunarFestivals > jieQi > solarFestival > solarOtherFestival

    // 1. Highest priority: Lunar festivals
    final lunarFestivals = lunarDate.getFestivals();
    if (lunarFestivals.isNotEmpty) {
      return lunarFestivals.first;
    }

    // 2. Second priority: Jie Qi (solar terms)
    final jieQi = lunarDate.getJieQi();
    if (jieQi.isNotEmpty) {
      return jieQi;
    }

    // 3. Third priority: Solar festivals
    final solarFestivals = solarDate.getFestivals();
    final solarFestival = solarFestivals.isNotEmpty
        ? solarFestivals.first
        : null;
    if (solarFestival != null && solarFestival.isNotEmpty) {
      return solarFestival;
    }

    return lunarDate.getDayInChinese();
  }

  /// Get the text color for lunar text based on content type
  Color? _getLunarTextColor(
    String lunarText,
    Lunar lunarDate,
    Solar solarDate, {
    Color? defaultColor,
  }) {
    // Check if it's a lunar festival or jie qi (use red)
    final lunarFestivals = lunarDate.getFestivals();
    final jieQi = lunarDate.getJieQi();

    if (lunarFestivals.isNotEmpty && lunarText == lunarFestivals.first) {
      return AppTheme.chineseRed;
    }

    if (jieQi.isNotEmpty && lunarText == jieQi) {
      return AppTheme.chineseRed;
    }

    // Check if it's a solar festival (use light blue)
    final solarFestivals = solarDate.getFestivals();
    final solarFestival = solarFestivals.isNotEmpty
        ? solarFestivals.first
        : null;
    if (solarFestival != null && lunarText == solarFestival) {
      return AppTheme.darkBlue; // Darker blue color for solar festivals
    }

    // Solar other festivals use default color
    return defaultColor;
  }

  DateTime _normalizeToLocalDate(DateTime date) {
    final local = date.isUtc ? date.toLocal() : date;
    return DateTime(local.year, local.month, local.day);
  }

  /// Get the zodiac animal emoji for the given lunar date
  String _getZodiacIcon(String shengXiao) {
    const zodiacIcons = {
      '鼠': '🐭', // Rat
      '牛': '🐮', // Ox
      '虎': '🐯', // Tiger
      '兔': '🐰', // Rabbit
      '龙': '🐲', // Dragon
      '蛇': '🐍', // Snake
      '马': '🐴', // Horse
      '羊': '🐑', // Goat/Sheep
      '猴': '🐵', // Monkey
      '鸡': '🐔', // Rooster
      '狗': '🐶', // Dog
      '猪': '🐷', // Pig
    };
    return zodiacIcons[shengXiao] ?? '';
  }

  /// Get the lunar date text with zodiac icon for the title bar
  Map<String, String> _getLunarDateTitleParts(DateTime date) {
    final normalized = _normalizeToLocalDate(date);
    final lunarDate = Lunar.fromDate(normalized);
    final shengXiao = lunarDate.getYearShengXiao();
    final zodiacIcon = _getZodiacIcon(shengXiao);
    final dateStr =
        '${lunarDate.getMonthInChinese()}月${lunarDate.getDayInChinese()}';

    return {'icon': zodiacIcon, 'date': dateStr};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Get the date to display in title bar - use selected date if available,
    // otherwise focused day
    final titleDate = _selectedDay ?? _focusedDay;
    final lunarTitleParts = _getLunarDateTitleParts(titleDate);
    final zodiacIcon = lunarTitleParts['icon'] ?? '';
    final lunarDateStr = lunarTitleParts['date'] ?? '';

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                zodiacIcon,
                style: const TextStyle(
                  fontSize: 24, // Larger size for the emoji
                ),
              ),
              const SizedBox(width: 8),
              Text(
                lunarDateStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const TodayIcon(),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = null;
                });
              },
              tooltip: l10n.today,
            ),
          ],
        ),
        body: Column(
          children: [
            // 日历组件
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 计算可用尺寸，使用响应式设计
                  final availableWidth = constraints.maxWidth;
                  final availableHeight = constraints.maxHeight;

                  // 计算当前月份需要的行数以调整其他参数
                  final rowsNeeded = _calculateRowsNeededForMonth(
                    _focusedDay,
                    _sundayFirst,
                  );

                  // 为500x450固定窗口优化的尺寸参数
                  // 使用更小的字体以确保有足够空间
                  final baseFontSize = (availableWidth / 55).clamp(
                    9.0,
                    12.0,
                  );

                  // 计算月份标题的高度（TableCalendar内部的header）
                  final headerFontSize = (baseFontSize * 1.2).clamp(14.0, 18.0);
                  final headerPadding = (baseFontSize * 0.15).clamp(1.0, 3.0);
                  final calendarHeaderHeight =
                      headerFontSize + headerPadding * 2 + 10.0; // 增加额外间距

                  // 星期标题高度 - 使用紧凑的布局
                  final daysOfWeekHeight = (baseFontSize * 1.8).clamp(
                    20.0,
                    24.0,
                  );

                  // 计算日期行可用的剩余高度
                  // 从总高度中减去：月份标题高度 + 星期标题高度 + 底部安全边距
                  // 关键：必须留出足够的底部边距，确保最后一行完全可见
                  // 动态调整底部边距：4行月份可以使用更小的边距以更好地填充空间
                  final double bottomSafetyMargin;
                  if (rowsNeeded == 6) {
                    bottomSafetyMargin = 30.0; // 6行需要更多边距
                  } else if (rowsNeeded == 5) {
                    bottomSafetyMargin = 25.0; // 5行使用标准边距
                  } else {
                    bottomSafetyMargin = 20.0; // 4行使用更小边距以更好填充空间
                  }
                  final remainingHeight =
                      availableHeight -
                      calendarHeaderHeight -
                      daysOfWeekHeight -
                      bottomSafetyMargin;

                  // 根据实际需要的行数动态调整行高
                  // 关键：严格控制行高，确保所有行都完全可见
                  // 动态调整行高以充分利用可用空间，避免底部空白过多
                  final double rowHeight;
                  if (rowsNeeded == 6) {
                    // 6行月份：使用紧凑的行高，确保第6行完全可见
                    rowHeight = (remainingHeight / 6.0).clamp(40.0, 52.0);
                  } else if (rowsNeeded == 5) {
                    // 5行月份：使用稍紧凑的行高
                    rowHeight = (remainingHeight / 5.0).clamp(45.0, 60.0);
                  } else {
                    // 4行月份：增加行高以充分利用可用空间，避免底部空白过多
                    rowHeight = (remainingHeight / 4.0).clamp(50.0, 75.0);
                  }

                  // 计算单元格大小用于动态样式
                  final cellSize = (availableWidth / 7).clamp(50.0, 80.0);

                  return TableCalendar<dynamic>(
                    focusedDay: _focusedDay,
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    daysOfWeekHeight: daysOfWeekHeight,
                    rowHeight: rowHeight,
                    locale: Localizations.localeOf(context).toString(),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      // Minimize cell margin for wider highlights
                      cellMargin: EdgeInsets.zero,
                      // Style for outside days (previous/next month)
                      outsideTextStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: baseFontSize,
                      ),
                      // 移除周末样式设置，因为我们在自定义builder中处理
                      // Default text style
                      defaultTextStyle: TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      // 星期标题样式，确保与日期行有足够间距
                      weekdayStyle: TextStyle(
                        fontSize: (baseFontSize * 0.9).clamp(10.0, 14.0),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      weekendStyle: TextStyle(
                        fontSize: (baseFontSize * 0.9).clamp(10.0, 14.0),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.chineseRed, // 周末星期标题使用红色
                      ),
                    ),
                    startingDayOfWeek: _sundayFirst
                        ? StartingDayOfWeek.sunday
                        : StartingDayOfWeek.monday,
                    calendarBuilders: CalendarBuilders(
                      headerTitleBuilder: (context, day) {
                        final locale = Localizations.localeOf(context);
                        final yearFormatter = DateFormat.y(locale.toString());
                        final monthFormatter = DateFormat.MMMM(
                          locale.toString(),
                        );

                        return Container(
                          padding: EdgeInsets.all(headerPadding),
                          child: Center(
                            child: InkWell(
                              onTap: _showYearMonthPicker,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      yearFormatter.format(day),
                                      style: TextStyle(
                                        fontSize: headerFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      monthFormatter.format(day),
                                      style: TextStyle(
                                        fontSize: headerFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildDateCell(
                          day,
                          false,
                          false,
                          cellSize,
                          availableRowHeight: rowHeight,
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        // Check if selected day is also today
                        final isToday = isSameDay(day, DateTime.now());
                        return _buildDateCell(
                          day,
                          true,
                          isToday,
                          cellSize,
                          availableRowHeight: rowHeight,
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildDateCell(
                          day,
                          false,
                          true,
                          cellSize,
                          availableRowHeight: rowHeight,
                        );
                      },
                      // 添加 outsideBuilder 确保非当月日期也使用相同的自定义样式
                      outsideBuilder: (context, day, focusedDay) {
                        // 只显示当月最后一天所在行的下个月日期
                        if (_shouldShowOutsideDay(day, focusedDay)) {
                          return _buildOutsideDateCell(
                            day,
                            false,
                            false,
                            cellSize,
                            availableRowHeight: rowHeight,
                          );
                        }
                        // 不显示其他非当月日期
                        return const SizedBox.shrink();
                      },
                    ),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
