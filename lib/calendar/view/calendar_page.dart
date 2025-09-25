import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';
import 'package:table_calendar/table_calendar.dart';
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

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
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
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color? backgroundColor;
    Color? textColor;
    Color? lunarTextColor;
    EdgeInsets margin;
    EdgeInsets padding;
    double borderRadius;
    List<BoxShadow>? boxShadow;

    // 根据单元格大小动态计算样式参数，更激进的缩放
    final dynamicPadding = (cellSize * 0.08).clamp(2.0, 8.0);
    final dynamicBorderRadius = (cellSize * 0.15).clamp(4.0, 16.0);

    // 非当月日期使用灰色文字，但保持相同的大小和布局
    backgroundColor = null;
    if (isWeekend) {
      // 周末日期使用红色，但因为是非当月日期，所以使用较淡的红色
      textColor = Colors.red.withValues(alpha: 0.4);
    } else {
      textColor = Colors.grey[400]; // 非当月日期使用灰色
    }
    // 农历文字保持原有的灰色样式
    lunarTextColor = Colors.grey[400];
    margin = EdgeInsets.zero;
    padding = EdgeInsets.symmetric(
      horizontal: dynamicPadding,
      vertical: dynamicPadding,
    );
    borderRadius = dynamicBorderRadius;
    boxShadow = null;

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

    return Container(
      margin: margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use available space more flexibly, don't force aspect ratio
          // if it causes overflow
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: boxShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 公历日期
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: primaryFontSize,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                // 农历日期 - 只在单元格足够大时显示
                if (showLunarText)
                  Text(
                    lunarDate.getDayInChinese(),
                    style: TextStyle(
                      fontSize: secondaryFontSize,
                      color: lunarTextColor?.withValues(alpha: 0.7), // 农历文字保持灰色
                      height: 1,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color? backgroundColor;
    Color? textColor;
    Color? lunarTextColor;
    EdgeInsets margin;
    EdgeInsets padding;
    double borderRadius;
    List<BoxShadow>? boxShadow;

    // 根据单元格大小动态计算样式参数，更激进的缩放
    final dynamicPadding = (cellSize * 0.08).clamp(2.0, 8.0);
    final dynamicBorderRadius = (cellSize * 0.15).clamp(4.0, 16.0);

    if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
      lunarTextColor = Colors.white;
      // Add horizontal margin to create narrower, more proportioned highlight
      final horizontalMargin = (cellSize * 0.12).clamp(3.0, 8.0);
      margin = EdgeInsets.symmetric(horizontal: horizontalMargin);
      padding = EdgeInsets.symmetric(
        horizontal: dynamicPadding,
        vertical: dynamicPadding,
      );
      borderRadius = dynamicBorderRadius;
      // Add subtle shadow for better visual hierarchy - more refined
      boxShadow = [
        BoxShadow(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          blurRadius: 2,
        ),
      ];
    } else if (isToday) {
      backgroundColor = Theme.of(context).primaryColor.withValues(alpha: 0.15);
      textColor = Theme.of(context).primaryColor;
      lunarTextColor = Theme.of(context).primaryColor;
      // Same margin and border radius as selected for consistency
      final horizontalMargin = (cellSize * 0.12).clamp(3.0, 8.0);
      margin = EdgeInsets.symmetric(horizontal: horizontalMargin);
      padding = EdgeInsets.symmetric(
        horizontal: dynamicPadding,
        vertical: dynamicPadding,
      );
      borderRadius = dynamicBorderRadius;
      boxShadow = null;
    } else {
      backgroundColor = null;
      if (isWeekend) {
        // 周末日期使用红色
        textColor = Colors.red;
      } else {
        textColor = null;
      }
      // 农历文字保持原有样式，不受周末影响
      lunarTextColor = null;
      margin = EdgeInsets.zero;
      padding = EdgeInsets.symmetric(
        horizontal: dynamicPadding,
        vertical: dynamicPadding,
      );
      borderRadius = dynamicBorderRadius;
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

    return Container(
      margin: margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use available space more flexibly, don't force aspect ratio
          // if it causes overflow
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: isToday && !isSelected
                  ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    )
                  : null,
              boxShadow: boxShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 公历日期
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: primaryFontSize,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                // 农历日期 - 只在单元格足够大时显示
                if (showLunarText)
                  Text(
                    lunarDate.getDayInChinese(),
                    style: TextStyle(
                      fontSize: secondaryFontSize,
                      color:
                          lunarTextColor ??
                          Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 计算指定月份需要多少行来显示
  /// 返回值为5或6，表示该月份在日历中需要的行数
  int _calculateRowsNeededForMonth(DateTime focusedDay) {
    // 获取当月第一天
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month);
    // 获取当月最后一天
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    // 计算第一天是星期几（0=周一, 6=周日）
    final firstDayWeekday = (firstDayOfMonth.weekday - 1) % 7;

    // 计算当月总天数
    final daysInMonth = lastDayOfMonth.day;

    // 计算需要的总格子数：前面填充的天数 + 当月天数
    final totalCells = firstDayWeekday + daysInMonth;

    // 计算需要的行数（每行7天）
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarAppBarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
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

                // 为500x500固定窗口优化的尺寸参数，同时保持响应性
                // 增大字体基础大小，提升可读性，但在极小窗口中保持保守
                final double baseFontSize;
                if (availableHeight < 350 || availableWidth < 350) {
                  // 极小窗口：使用更保守的字体大小
                  baseFontSize = (availableWidth / 50).clamp(9.0, 13.0);
                } else {
                  // 正常窗口：使用改进的字体大小
                  baseFontSize = (availableWidth / 45).clamp(11.0, 16.0);
                }

                // 计算当前月份需要的行数以调整其他参数
                final rowsNeeded = _calculateRowsNeededForMonth(_focusedDay);

                // 根据行数需求调整间距参数
                // 增加星期标题高度，避免与日期行重叠，但在极小窗口中保持保守
                final double daysOfWeekHeight;
                if (availableHeight < 350) {
                  // 极小窗口：使用更保守的星期标题高度
                  daysOfWeekHeight = (baseFontSize * 1.5).clamp(
                    rowsNeeded == 6 ? 12.0 : 14.0,
                    24.0,
                  );
                } else {
                  // 正常窗口：使用改进的星期标题高度
                  daysOfWeekHeight = (baseFontSize * 2.0).clamp(
                    rowsNeeded == 6 ? 16.0 : 20.0,
                    32.0,
                  );
                }

                final headerPadding = (availableHeight * 0.02).clamp(
                  rowsNeeded == 6 ? 4.0 : 6.0, // 6行月份使用稍小的头部内边距
                  20.0,
                );
                final remainingHeight =
                    availableHeight - daysOfWeekHeight - headerPadding;

                // 根据实际需要的行数动态调整行高
                // 计算最小内容高度需求
                final minContentHeight = baseFontSize * 2.4; // 主文字 + 农历文字 + 间距
                const minCellPadding = 4.0; // 增加最小内边距
                final minRowHeight = minContentHeight + minCellPadding * 2;

                // 为6行月份预留更合理的间距，减少底部空白
                // 改进的计算策略：为6行月份提供更好的垂直空间利用
                final double rowHeight;
                if (rowsNeeded == 6) {
                  // 6行月份：更积极的动态调整策略，显著增加行间距以减少底部空白
                  final double divisor;
                  switch (availableHeight) {
                    case < 300:
                      // 极小窗口：使用保守的除数防止溢出
                      divisor = 9.0;
                    case < 400:
                      // 小窗口：更积极地增加空间
                      divisor = 7.5;
                    case < 500:
                      // 中等窗口：显著增加空间
                      divisor = 6.8;
                    default:
                      // 正常窗口：更积极地利用垂直空间，减少底部空白
                      divisor = 6.5;
                  }
                  final idealHeight = remainingHeight / divisor;
                  rowHeight = idealHeight.clamp(
                    minRowHeight,
                    55.0,
                  ); // 从 51.0 增加到 55.0，允许更大的行高
                } else {
                  // 5行月份：使用更宽松的布局，减少底部空白
                  final double divisor;
                  switch (availableHeight) {
                    case < 300:
                      // 极小窗口：更保守
                      divisor = 7.0;
                    case < 400:
                      // 小窗口：适中
                      divisor = 6.2;
                    default:
                      // 正常窗口：更宽松
                      divisor = 5.8;
                  }
                  final idealHeight = remainingHeight / divisor;
                  rowHeight = idealHeight.clamp(
                    minRowHeight,
                    70.0,
                  ); // 保持原值 70.0 上限
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
                      color: Colors.red, // 周末星期标题使用红色
                    ),
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      final locale = Localizations.localeOf(context);
                      final formatter = DateFormat.yMMMM(locale.toString());
                      final headerFontSize = (baseFontSize * 1.2).clamp(
                        16.0,
                        22.0,
                      );
                      return Container(
                        padding: EdgeInsets.all(
                          (baseFontSize * 0.15).clamp(1.0, 4.0),
                        ), // 更激进地减少年月标题的内边距
                        child: Text(
                          formatter.format(day),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: headerFontSize,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
                      return _buildDateCell(
                        day,
                        true,
                        false,
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
    );
  }
}
