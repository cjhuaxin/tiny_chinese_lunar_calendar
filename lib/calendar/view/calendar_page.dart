import 'package:ccalendar/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              widget.onLanguageChanged?.call(locale);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<Locale>(
                value: Locale('en'),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('zh'),
                child: Text('中文'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 日历组件
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 计算可用高度，减去星期标题的高度和一些内部padding
                final availableHeight = constraints.maxHeight;
                const daysOfWeekHeight = 40.0;
                const padding = 65.0; // 为内部padding和边距预留更多空间
                final remainingHeight =
                    availableHeight - daysOfWeekHeight - padding;
                // 6行日期，每行平均分配剩余高度
                final rowHeight = (remainingHeight / 6).clamp(
                  50.0,
                  double.infinity,
                );

                return TableCalendar<dynamic>(
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

                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      final locale = Localizations.localeOf(context);
                      final formatter = DateFormat.yMMMM(locale.toString());
                      return Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          formatter.format(day),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
