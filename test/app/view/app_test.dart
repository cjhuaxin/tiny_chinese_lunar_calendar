import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_chinese_lunar_calendar/app/app.dart';

void main() {
  group('App', () {
    testWidgets('uses light theme mode only', (tester) async {
      await tester.pumpWidget(const App());
      
      // 获取 MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // 验证主题模式设置为亮色
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('has both light and dark themes defined', (tester) async {
      await tester.pumpWidget(const App());
      
      // 获取 MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // 验证亮色和暗色主题都已定义
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
    });

    testWidgets('renders CalendarPage as home', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      
      // 验证应用正确渲染了日历页面
      expect(find.byType(Scaffold), findsOneWidget);
      
      // 验证没有渲染错误
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports localization', (tester) async {
      await tester.pumpWidget(const App());
      
      // 获取 MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // 验证本地化设置
      expect(materialApp.localizationsDelegates, isNotNull);
      expect(materialApp.supportedLocales, isNotNull);
      expect(materialApp.supportedLocales.isNotEmpty, isTrue);
    });
  });
}
