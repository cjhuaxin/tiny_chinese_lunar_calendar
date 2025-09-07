# 国际化功能说明 / Internationalization Guide

## 概述 / Overview

这个Flutter日历应用已经支持多语言国际化，目前支持：
- 🇺🇸 英语 (English)
- 🇨🇳 中文 (Chinese)

## 功能特性 / Features

### 1. 语言切换 / Language Switching
- 点击右上角的语言图标 🌐
- 从下拉菜单中选择语言
- 应用会立即切换到选择的语言

### 2. 日历国际化 / Calendar Internationalization
- **月份显示**: 根据选择的语言显示月份名称
- **星期显示**: 星期几会根据语言显示
- **日期格式**: 选中日期的显示格式会根据语言调整

### 3. 界面文本国际化 / UI Text Internationalization
- 应用标题
- 按钮文本
- 提示信息
- 日期选择状态

## 技术实现 / Technical Implementation

### ARB文件结构 / ARB File Structure
```
lib/l10n/arb/
├── app_en.arb    # 英语翻译
├── app_zh.arb    # 中文翻译
└── app_es.arb    # 西班牙语翻译
```

### 主要配置 / Main Configuration
1. **pubspec.yaml**: 已配置 `flutter_localizations` 和 `intl`
2. **l10n.yaml**: 国际化生成配置
3. **MaterialApp**: 配置了 `localizationsDelegates` 和 `supportedLocales`

### TableCalendar国际化 / TableCalendar Internationalization
- 使用 `locale` 参数传递当前语言环境
- 自定义 `headerTitleBuilder` 来格式化月份显示
- 支持不同语言的日期格式

## 使用方法 / Usage

### 运行应用 / Running the App
```bash
flutter run lib/main_development.dart -d chrome
```

### 测试语言切换 / Testing Language Switching
1. 启动应用
2. 点击右上角的语言图标
3. 选择不同的语言
4. 观察界面文本和日历显示的变化

### 添加新语言 / Adding New Languages
1. 在 `lib/l10n/arb/` 目录下创建新的ARB文件
2. 运行 `flutter gen-l10n` 重新生成国际化文件
3. 在语言选择菜单中添加新语言选项

## 支持的文本 / Supported Text

| 键值 | 英语 | 中文 |
|------|------|------|----------|
| calendarAppBarTitle | Chinese Calendar | 中国日历 |
| today | Today | 今天 |
| selectDate | Select Date | 选择日期 |
| noDateSelected | No date selected | 未选择日期 |
| selectedDate | Selected: {date} | 已选择：{date} |

## 注意事项 / Notes

1. **日期格式**: 不同语言的日期格式会自动调整
2. **RTL支持**: 目前不支持从右到左的语言
3. **字体**: 确保设备支持所选语言的字体显示
4. **热重载**: 语言切换后需要重启应用才能完全生效

## 开发者指南 / Developer Guide

### 添加新的翻译文本 / Adding New Translation Text
1. 在所有ARB文件中添加新的键值对
2. 运行 `flutter gen-l10n`
3. 在代码中使用 `context.l10n.yourNewKey`

### 自定义日期格式 / Custom Date Formatting
```dart
final formatter = DateFormat.yMMMd(Localizations.localeOf(context).toString());
```

### 获取当前语言环境 / Getting Current Locale
```dart
final locale = Localizations.localeOf(context);
```
