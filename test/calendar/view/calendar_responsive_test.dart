import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/calendar/view/calendar_page.dart';
import 'package:tiny_chinese_lunar_calendar/l10n/l10n.dart';

void main() {
  // 辅助函数：创建带有本地化设置的MaterialApp
  Widget createTestApp() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: CalendarPage(),
    );
  }

  group('Calendar Responsive Design Tests', () {
    testWidgets('Calendar should adapt to small window size', (tester) async {
      // 测试固定窗口尺寸 (500x500)
      await tester.binding.setSurfaceSize(const Size(500, 500));

      await tester.pumpWidget(createTestApp());

      // 验证日历组件是否正确渲染
      expect(find.byType(CalendarPage), findsOneWidget);

      // 验证没有渲染溢出错误
      expect(tester.takeException(), isNull);
    });

    testWidgets('Calendar should adapt to medium window size', (tester) async {
      // 测试中等窗口尺寸 (700x550)
      await tester.binding.setSurfaceSize(const Size(700, 550));

      await tester.pumpWidget(createTestApp());

      // 验证日历组件是否正确渲染
      expect(find.byType(CalendarPage), findsOneWidget);

      // 验证没有渲染溢出错误
      expect(tester.takeException(), isNull);
    });

    testWidgets('Calendar should adapt to large window size', (tester) async {
      // 测试大窗口尺寸 (1200x800)
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(createTestApp());

      // 验证日历组件是否正确渲染
      expect(find.byType(CalendarPage), findsOneWidget);

      // 验证没有渲染溢出错误
      expect(tester.takeException(), isNull);
    });

    testWidgets('Calendar should handle fixed window size', (tester) async {
      // 测试固定窗口尺寸 (500x500)
      await tester.binding.setSurfaceSize(const Size(500, 500));

      await tester.pumpWidget(createTestApp());

      // 验证固定窗口渲染正常
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 测试稍大的窗口
      await tester.binding.setSurfaceSize(const Size(600, 600));
      await tester.pump();

      // 验证仍然正常
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 回到固定尺寸
      await tester.binding.setSurfaceSize(const Size(500, 500));
      await tester.pump();

      // 验证固定尺寸仍然正常
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
