import 'package:flutter/material.dart';

/// 中国万年历应用主题配色
/// 采用中国红为主色调，营造传统文化氛围
class AppTheme {
  // 中国红色系配色 - 更现代化的中国红调色板
  static const Color _chineseRed = Color(
    0xFFD32F2F,
  ); // 主要的中国红，更接近Flutter Debug Banner
  static const Color _deepRed = Color(0xFFB71C1C); // 深红色，用于错误状态
  static const Color _lightRed = Color(0xFFE57373); // 浅红色
  static const Color _softRed = Color(0xFFFFEBEE); // 非常柔和的红色背景

  // 辅助色彩
  static const Color _darkBlue = Color(0xFF1976D2); // 更沉稳的蓝色
  static const Color _goldAccent = Color(0xFFFF8F00); // 更温暖的金色
  static const Color _warmGray = Color(0xFF424242); // 现代化的深灰色
  static const Color _lightGray = Color(0xFFFAFAFA); // 更纯净的浅灰色背景

  /// 获取深蓝色，用于日历中的节日显示
  static Color get darkBlue => _darkBlue;

  /// 获取中国红色，用于日历中的重要日期
  static Color get chineseRed => _chineseRed;

  /// 获取亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _chineseRed,
        primary: _chineseRed,
        onPrimary: Colors.white,
        secondary: _goldAccent,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: _warmGray,
        error: _deepRed,
        onError: Colors.white,
      ),

      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: _chineseRed,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 48, // 减少AppBar高度，默认是56
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18, // 稍微减少字体大小
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _chineseRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _chineseRed,
        ),
      ),

      // 图标按钮主题 - 不设置全局前景色，让AppBar的iconTheme优先
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _chineseRed, width: 2),
        ),
        labelStyle: const TextStyle(color: _warmGray),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),

      // 文本主题
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _warmGray,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _warmGray,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _warmGray,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _warmGray,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: _warmGray,
        ),
        bodyMedium: TextStyle(
          color: _warmGray,
        ),
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
    );
  }

  /// 获取暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _chineseRed,
        brightness: Brightness.dark,
        primary: _lightRed,
        onPrimary: Colors.white,
        secondary: _goldAccent,
        onSecondary: Colors.black,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
        error: _lightRed,
        onError: Colors.white,
      ),

      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),

      // 卡片主题
      cardTheme: const CardThemeData(
        color: Color(0xFF2D2D2D),
        elevation: 2,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightRed,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightRed,
        ),
      ),

      // 图标按钮主题 - 不设置全局前景色，让AppBar的iconTheme优先
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(),
      ),
    );
  }
}
