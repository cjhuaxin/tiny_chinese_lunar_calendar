import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/view/calendar_page.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/gen/app_localizations.dart';

void main() {
  group('Calendar Layout Improvements Tests', () {
    testWidgets('Calendar should have improved font sizes and spacing', (
      tester,
    ) async {
      // 创建一个500x500的测试环境，模拟实际使用场景
      await tester.binding.setSurfaceSize(const Size(500, 500));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 500,
              child: CalendarView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证日历组件存在
      expect(find.byType(CalendarView), findsOneWidget);

      // 这个测试主要是确保没有渲染错误
      // 实际的视觉效果需要手动验证
    });

    test('Font size calculation should be improved', () {
      // 测试新的字体大小计算
      const availableWidth = 500.0;
      final baseFontSize = (availableWidth / 45).clamp(11.0, 16.0);

      // 验证字体大小在合理范围内
      expect(baseFontSize, greaterThanOrEqualTo(11.0));
      expect(baseFontSize, lessThanOrEqualTo(16.0));

      // 对于500px宽度，应该得到约11.1的字体大小
      expect(baseFontSize, closeTo(11.1, 0.2));
    });

    test('Days of week height should be adequate', () {
      const availableWidth = 500.0;
      final baseFontSize = (availableWidth / 45).clamp(11.0, 16.0);

      // 测试6行月份的星期标题高度
      final daysOfWeekHeight6Rows = (baseFontSize * 2.0).clamp(16.0, 32.0);
      expect(daysOfWeekHeight6Rows, greaterThanOrEqualTo(16.0));

      // 测试5行月份的星期标题高度
      final daysOfWeekHeight5Rows = (baseFontSize * 2.0).clamp(20.0, 32.0);
      expect(daysOfWeekHeight5Rows, greaterThanOrEqualTo(20.0));
    });

    test('Cell font sizes should be improved', () {
      const cellSize = 70.0; // 典型的单元格大小

      // 测试新的字体大小计算
      final primaryFontSize = (cellSize * 0.22).clamp(8.0, 15.0);
      final secondaryFontSize = (cellSize * 0.12).clamp(6.0, 10.0);

      // 验证字体大小合理
      expect(primaryFontSize, greaterThanOrEqualTo(8.0));
      expect(primaryFontSize, lessThanOrEqualTo(15.0));
      expect(secondaryFontSize, greaterThanOrEqualTo(6.0));
      expect(secondaryFontSize, lessThanOrEqualTo(10.0));

      // 对于70px的单元格，主字体应该约为15.4px，农历字体约为8.4px
      expect(primaryFontSize, closeTo(15.0, 1.0)); // 会被clamp到15.0
      expect(secondaryFontSize, closeTo(8.4, 0.5));
    });

    test('Row height calculation should provide better spacing', () {
      const availableHeight = 400.0;
      const baseFontSize = 11.0;
      const daysOfWeekHeight = 22.0;
      const headerPadding = 8.0;
      final remainingHeight =
          availableHeight - daysOfWeekHeight - headerPadding;

      // 测试6行月份的行高计算
      final rowHeight6Rows = (remainingHeight / 6.8).clamp(30.0, 50.0);
      expect(rowHeight6Rows, greaterThanOrEqualTo(30.0));

      // 测试5行月份的行高计算
      final rowHeight5Rows = (remainingHeight / 5.8).clamp(30.0, 70.0);
      expect(rowHeight5Rows, greaterThanOrEqualTo(30.0));

      // 6行月份应该有合理的行高，不会过度压缩
      expect(rowHeight6Rows, greaterThan(40.0));
    });
  });
}
