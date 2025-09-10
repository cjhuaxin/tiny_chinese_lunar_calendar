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
  const CalendarView({super.key, this.onLanguageChanged});

  final void Function(Locale)? onLanguageChanged;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime? _selectedDay;
  DateTime _focusedDay = kToday;

  /// 构建非当月日期单元格，同时显示公历和农历日期
  Widget _buildOutsideDateCell(
    DateTime day,
    bool isSelected,
    bool isToday,
    double cellSize, {
    double? availableRowHeight,
  }) {
    final lunarDate = Lunar.fromDate(day);

    Color? backgroundColor;
    Color? textColor;
    EdgeInsets margin;
    EdgeInsets padding;
    double borderRadius;
    List<BoxShadow>? boxShadow;

    // 根据单元格大小动态计算样式参数，更激进的缩放
    final dynamicPadding = (cellSize * 0.08).clamp(2.0, 8.0);
    final dynamicBorderRadius = (cellSize * 0.15).clamp(4.0, 16.0);

    // 非当月日期使用灰色文字，但保持相同的大小和布局
    backgroundColor = null;
    textColor = Colors.grey[400]; // 非当月日期使用灰色
    margin = EdgeInsets.zero;
    padding = EdgeInsets.symmetric(
      horizontal: dynamicPadding,
      vertical: dynamicPadding,
    );
    borderRadius = dynamicBorderRadius;
    boxShadow = null;

    // 根据单元格大小和可用行高动态计算字体大小，与当月日期保持一致
    // 使用更保守的缩放以防止溢出
    final basePrimaryFontSize = (cellSize * 0.18).clamp(6.0, 12.0);
    final baseSecondaryFontSize = (cellSize * 0.10).clamp(4.0, 8.0);

    // 如果有可用行高信息，进一步限制字体大小
    final primaryFontSize = availableRowHeight != null
        ? basePrimaryFontSize.clamp(
            6.0,
            (availableRowHeight * 0.30).clamp(6.0, 12.0),
          )
        : basePrimaryFontSize;
    final secondaryFontSize = availableRowHeight != null
        ? baseSecondaryFontSize.clamp(
            4.0,
            (availableRowHeight * 0.18).clamp(4.0, 8.0),
          )
        : baseSecondaryFontSize;

    // 在极小的单元格或行高中隐藏农历文本
    // 增加更严格的条件以防止在极端约束下溢出
    final showLunarText =
        cellSize > 30 &&
        (availableRowHeight == null || availableRowHeight > 24) &&
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
                      color: textColor?.withValues(alpha: 0.7), // 农历文字更淡一些
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

    Color? backgroundColor;
    Color? textColor;
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
      // No margin at all for maximum width, create square-like effect
      margin = EdgeInsets.zero;
      padding = EdgeInsets.symmetric(
        horizontal: dynamicPadding,
        vertical: dynamicPadding,
      );
      borderRadius = dynamicBorderRadius;
      // Add subtle shadow for better visual hierarchy
      boxShadow = [
        BoxShadow(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
          blurRadius: 2,
        ),
      ];
    } else if (isToday) {
      backgroundColor = Theme.of(context).primaryColor.withValues(alpha: 0.15);
      textColor = Theme.of(context).primaryColor;
      // Same margin and border radius as selected for consistency
      margin = EdgeInsets.zero;
      padding = EdgeInsets.symmetric(
        horizontal: dynamicPadding,
        vertical: dynamicPadding,
      );
      borderRadius = dynamicBorderRadius;
      boxShadow = null;
    } else {
      backgroundColor = null;
      textColor = null;
      margin = EdgeInsets.zero;
      padding = EdgeInsets.symmetric(
        horizontal: dynamicPadding,
        vertical: dynamicPadding,
      );
      borderRadius = dynamicBorderRadius;
      boxShadow = null;
    }

    // 根据单元格大小和可用行高动态计算字体大小
    // 使用更保守的缩放以防止溢出
    final basePrimaryFontSize = (cellSize * 0.18).clamp(6.0, 12.0);
    final baseSecondaryFontSize = (cellSize * 0.10).clamp(4.0, 8.0);

    // 如果有可用行高信息，进一步限制字体大小
    final primaryFontSize = availableRowHeight != null
        ? basePrimaryFontSize.clamp(
            6.0,
            (availableRowHeight * 0.30).clamp(6.0, 12.0),
          )
        : basePrimaryFontSize;
    final secondaryFontSize = availableRowHeight != null
        ? baseSecondaryFontSize.clamp(
            4.0,
            (availableRowHeight * 0.18).clamp(4.0, 8.0),
          )
        : baseSecondaryFontSize;

    // 在极小的单元格或行高中隐藏农历文本
    // 增加更严格的条件以防止在极端约束下溢出
    final showLunarText =
        cellSize > 30 &&
        (availableRowHeight == null || availableRowHeight > 24) &&
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
                          textColor ??
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
                _focusedDay = kToday;
                _selectedDay = kToday;
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
                final baseFontSize = (availableWidth / 50).clamp(9.0, 14.0);

                // 计算当前月份需要的行数以调整其他参数
                final rowsNeeded = _calculateRowsNeededForMonth(_focusedDay);

                // 根据行数需求调整间距参数
                final daysOfWeekHeight = (baseFontSize * 1.5).clamp(
                  rowsNeeded == 6 ? 10.0 : 12.0, // 6行月份使用更小的星期标题高度
                  24.0,
                );
                final headerPadding = (availableHeight * 0.015).clamp(
                  rowsNeeded == 6 ? 2.0 : 4.0, // 6行月份使用更小的头部内边距
                  16.0,
                );
                final remainingHeight =
                    availableHeight - daysOfWeekHeight - headerPadding;

                // 根据实际需要的行数动态调整行高
                // 计算最小内容高度需求
                final minContentHeight = baseFontSize * 2.2; // 主文字 + 农历文字 + 间距
                const minCellPadding = 3.0; // 最小内边距
                final minRowHeight = minContentHeight + minCellPadding * 2;

                // 为6行月份预留更紧凑的间距，为5行月份提供更宽松的间距
                final double rowHeight;
                if (rowsNeeded == 6) {
                  // 6行月份：确保有足够空间显示内容，但保持紧凑
                  // 使用更保守的计算，留出更多缓冲空间防止溢出
                  final idealHeight = remainingHeight / 8.0; // 更大的除数，更多缓冲空间
                  rowHeight = idealHeight.clamp(minRowHeight, 42.0);
                } else {
                  // 5行月份：使用更宽松的布局，减少底部空白
                  // 计算可用空间并平均分配给5行
                  final idealHeight = remainingHeight / 6.2; // 留出一些缓冲空间
                  rowHeight = idealHeight.clamp(minRowHeight, 62.0);
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
                    // Weekend styling - 使用更柔和的红色
                    weekendTextStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                      fontSize: baseFontSize,
                    ),
                    // Default text style
                    defaultTextStyle: TextStyle(
                      fontSize: baseFontSize,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
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
