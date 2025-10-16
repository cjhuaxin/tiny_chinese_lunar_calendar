import 'package:flutter/material.dart';

/// A widget that displays Chinese holiday status tags (休/班)
/// 休 (xiū) - Rest day (green background)
/// 班 (bān) - Work day (red background)
class HolidayTag extends StatelessWidget {
  const HolidayTag({
    super.key,
    required this.isWorkDay,
    this.size = 16.0,
  });

  /// Whether this is a work day (true) or rest day (false)
  final bool isWorkDay;
  
  /// Size of the tag (diameter for circular tag)
  final double size;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isWorkDay 
        ? const Color(0xFFE53E3E)  // Red for work days (班)
        : const Color(0xFF38A169); // Green for rest days (休)
    
    final text = isWorkDay ? '班' : '休';
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6, // Font size relative to tag size
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
