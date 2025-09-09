import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/utils/lunar_calendar.dart';
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

  /// 构建日期单元格，同时显示公历和农历日期
  Widget _buildDateCell(
    DateTime day,
    bool isSelected,
    bool isToday,
    double cellSize,
  ) {
    final lunarDate = LunarCalendar.solarToLunar(day);

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
          color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
          blurRadius: 6,
          offset: const Offset(0, 3),
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

    // 根据单元格大小动态计算字体大小，更激进的缩放
    final primaryFontSize = (cellSize * 0.25).clamp(8.0, 16.0);
    final secondaryFontSize = (cellSize * 0.15).clamp(6.0, 10.0);

    // 在极小的单元格中隐藏农历文本
    final showLunarText = cellSize > 30;

    return Container(
      margin: margin,
      child: AspectRatio(
        aspectRatio: 0.95, // Force square aspect ratio
        child: Container(
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
                  lunarDate.dayText,
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
        ),
      ),
    );
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

                // 动态计算各种尺寸参数，更激进的缩放
                final baseFontSize = (availableWidth / 60).clamp(10.0, 18.0);
                final daysOfWeekHeight = (baseFontSize * 2.0).clamp(20.0, 35.0);
                final headerPadding = (availableHeight * 0.04).clamp(
                  20.0,
                  50.0,
                );
                final remainingHeight =
                    availableHeight - daysOfWeekHeight - headerPadding;

                // 6行日期，每行平均分配剩余高度，设置更小的最小值
                final rowHeight = (remainingHeight / 6).clamp(
                  20.0, // 进一步减小最小行高，允许更紧凑的布局
                  double.infinity,
                );

                // 计算单元格大小用于动态样式
                final cellSize = (availableWidth / 7).clamp(30.0, 120.0);

                return SingleChildScrollView(
                  child: TableCalendar<dynamic>(
                    focusedDay: _focusedDay,
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    sixWeekMonthsEnforced: true,
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
                          padding: EdgeInsets.all(baseFontSize * 0.3),
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
                        return _buildDateCell(day, false, false, cellSize);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildDateCell(day, true, false, cellSize);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildDateCell(day, false, true, cellSize);
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
                      _focusedDay = focusedDay;
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
