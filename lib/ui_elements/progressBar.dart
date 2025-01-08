import 'package:flutter/material.dart';

class CompletionProgressBar extends StatelessWidget {
  final num percentage;
  final double height;
  final Color backgroundColor;
  final Color progressColor;

  const CompletionProgressBar({
    Key? key,
    required this.percentage,
    this.height = 4,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure percentage is between 0 and 1
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    print("clamped percentage is $clampedPercentage");
    
    return Container(
      width: 50, // Fixed width for trailing area
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedPercentage/100,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Text('$percentage'),
        ),
      ),
    );
  }
}
