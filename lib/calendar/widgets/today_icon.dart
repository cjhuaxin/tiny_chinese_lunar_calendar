import 'package:flutter/material.dart';

/// A custom icon widget that displays the Chinese character "今" (today)
/// Designed to match the visual style of holiday tags without background styling
class TodayIcon extends StatelessWidget {
  const TodayIcon({
    super.key,
    this.size = 24.0,
    this.color,
  });

  /// Size of the icon (width and height)
  final double size;

  /// Color of the text, defaults to current icon theme color
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color;

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
          ),
        ),
        child: Center(
          child: Text(
            '今',
            style: TextStyle(
              color: iconColor,
              fontSize: size * 0.6, // Adjusted to fit within the circle
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
