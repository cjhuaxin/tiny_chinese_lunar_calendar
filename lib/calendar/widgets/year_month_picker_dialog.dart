import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A unified year-month picker dialog that combines year selection (upper 2/3)
/// and month selection (lower 1/3) in a single dialog interface.
class YearMonthPickerDialog extends StatefulWidget {
  const YearMonthPickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    super.key,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<YearMonthPickerDialog> createState() => _YearMonthPickerDialogState();
}

class _YearMonthPickerDialogState extends State<YearMonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late ScrollController _yearScrollController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;

    // Initialize scroll controller and calculate initial scroll position
    _yearScrollController = ScrollController();

    // Calculate scroll position to center the selected year
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedYear();
    });
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedYear() {
    final selectedIndex = _selectedYear - widget.firstDate.year;

    // Calculate item dimensions for 3 rows with 5 columns
    const crossAxisCount = 5;
    const itemHeight = 50.0; // Height of each year item
    const mainAxisSpacing = 8.0;

    // Calculate row of the selected year
    final selectedRow = selectedIndex ~/ crossAxisCount;

    // Calculate the offset to center the selected year vertically
    final rowOffset = selectedRow * (itemHeight + mainAxisSpacing);

    // Center the selected row in the viewport (3 visible rows)
    const visibleRows = 3;
    const viewportHeight =
        visibleRows * (itemHeight + mainAxisSpacing) - mainAxisSpacing;
    final centeredOffset = rowOffset - (viewportHeight / 2) + (itemHeight / 2);

    if (_yearScrollController.hasClients) {
      final totalRows =
          ((widget.lastDate.year - widget.firstDate.year + 1) / crossAxisCount)
              .ceil();
      final maxOffset =
          (totalRows * (itemHeight + mainAxisSpacing)) - viewportHeight;

      _yearScrollController.animateTo(
        centeredOffset.clamp(0.0, maxOffset > 0 ? maxOffset : 0.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildYearPicker() {
    final years = <int>[];
    for (
      var year = widget.firstDate.year;
      year <= widget.lastDate.year;
      year++
    ) {
      years.add(year);
    }

    return Container(
      height: 198, // Height for 3 rows: 3*50 + 2*8 + 2*16 padding
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          controller: _yearScrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // 5 columns
            childAspectRatio: 1.344, // Forces 50px height
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];
            final isSelected = year == _selectedYear;
            final isCurrentYear = year == DateTime.now().year;

            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _selectedYear = year;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  border: isCurrentYear && !isSelected
                      ? Border.all(
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected || isCurrentYear
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isCurrentYear
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthPicker() {
    final locale = Localizations.localeOf(context);

    // Generate month names using DateFormat for proper localization
    final months = List.generate(12, (index) {
      final date = DateTime(2024, index + 1);
      return DateFormat.MMMM(locale.toString()).format(date);
    });

    return Container(
      height: 120, // 1/3 of total dialog content area (300 * 1/3)
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, // 6 columns for 2 rows layout
          childAspectRatio: 1.8, // Reduced aspect ratio for more compact items
          crossAxisSpacing: 6, // Reduced spacing for better fit
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final isSelected = month == _selectedMonth;

          return Material(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              6,
            ), // Slightly smaller border radius
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                // Auto-confirm when month is selected
                final selectedDate = DateTime(_selectedYear, month);
                Navigator.of(context).pop(selectedDate);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    months[index],
                    style: TextStyle(
                      fontSize:
                          10, // Reduced font size for more compact display
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1, // Ensure single line display
                    overflow:
                        TextOverflow.ellipsis, // Handle overflow gracefully
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,

      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 400,
        height: 318, // Total content height
        child: Column(
          children: [
            // Year picker (2/3 of the space)
            _buildYearPicker(),
            // Month picker (1/3 of the space)
            _buildMonthPicker(),
          ],
        ),
      ),
    );
  }
}

/// Show the unified year-month picker dialog
Future<DateTime?> showYearMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return YearMonthPickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    },
  );
}
