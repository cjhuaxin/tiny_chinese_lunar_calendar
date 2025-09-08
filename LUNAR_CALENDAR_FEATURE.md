# 农历显示功能 / Lunar Calendar Feature

## 功能概述 / Feature Overview

本日历应用现在支持在每个公历日期下方显示对应的农历日期，实现了中西合璧的双历显示效果。

The calendar application now supports displaying the corresponding lunar calendar date below each Gregorian date, achieving a bilingual calendar display that combines both Western and Chinese calendar systems.

## 功能特性 / Features

### 1. 双历显示 / Dual Calendar Display
- 每个日期单元格同时显示公历和农历日期
- 公历日期显示在上方（较大字体）
- 农历日期显示在下方（较小字体，灰色）

### 2. 中文农历格式 / Chinese Lunar Format
- 农历日期使用传统中文格式：初一、初二、十五、廿一等
- 农历月份使用传统名称：正月、二月、冬月、腊月等
- 支持生肖年份和天干地支纪年

### 3. 视觉效果 / Visual Effects
- 选中日期：蓝色背景，白色文字
- 今天日期：蓝色边框，蓝色文字
- 普通日期：默认样式，农历日期为灰色

## 技术实现 / Technical Implementation

### 核心组件 / Core Components

1. **LunarCalendar 类** (`lib/calendar/utils/lunar_calendar.dart`)
   - 提供公历到农历的转换功能
   - 包含农历数据和格式化方法
   - 支持1900-2100年的日期转换

2. **LunarDate 类**
   - 农历日期数据模型
   - 提供多种文本格式化方法

3. **自定义日期单元格** (`lib/calendar/view/calendar_page.dart`)
   - 使用 TableCalendar 的自定义构建器
   - 实现双历显示布局

### 使用示例 / Usage Example

```dart
// 转换公历日期为农历
final solarDate = DateTime(2025, 1, 1);
final lunarDate = LunarCalendar.solarToLunar(solarDate);

print(lunarDate.dayText);    // "初二"
print(lunarDate.fullText);   // "腊月初二"
print(lunarDate.yearText);   // "甲辰年（龙年）"
```

## 测试验证 / Testing

### 单元测试
运行以下命令进行测试：
```bash
flutter test test/calendar/utils/lunar_calendar_test.dart
```

### 演示程序
运行演示程序查看转换效果：
```bash
dart run example/lunar_calendar_demo.dart
```

## 示例转换结果 / Example Conversions

| 公历日期 | 农历日期 | 说明 |
|---------|---------|------|
| 2025年1月1日 | 腊月初二 | 元旦 |
| 2025年1月29日 | 正月初一 | 春节 |
| 2025年6月1日 | 五月初六 | 儿童节 |
| 2025年10月1日 | 九月初十 | 国庆节 |

## 农历格式说明 / Lunar Format Guide

### 农历日期格式
- 1-10日：初一、初二、...、初十
- 11-19日：十一、十二、...、十九
- 20日：二十
- 21-29日：廿一、廿二、...、廿九
- 30日：三十

### 农历月份格式
- 1月：正月
- 2-10月：二月、三月、...、十月
- 11月：冬月
- 12月：腊月

## 注意事项 / Notes

1. **算法精度**：当前实现使用简化的农历算法，适用于一般显示需求
2. **日期范围**：支持1900-2100年的日期转换
3. **闰月处理**：当前版本暂不处理闰月，后续版本可以扩展
4. **性能优化**：农历转换在每次渲染时进行，对于大量日期可考虑缓存优化

## 未来扩展 / Future Enhancements

- [ ] 支持闰月显示
- [ ] 添加农历节日标注
- [ ] 支持其他历法系统
- [ ] 性能优化和缓存机制
- [ ] 更精确的农历算法

## 贡献 / Contributing

欢迎提交问题和改进建议！如果您发现农历转换的准确性问题，请提供具体的日期示例。
