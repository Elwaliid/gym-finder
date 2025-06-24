import 'package:flutter/material.dart';

class MonthTileWidget extends StatelessWidget {
  final DateTime? dateTime; // Make dateTime final for immutability
  const MonthTileWidget({
    super.key,
    required this.dateTime, // Make dateTime required
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center, // Center the text
      child: Text(
        dateTime == null ? "" : dateTime!.day.toString(),
        style: const TextStyle(
          fontSize: 12, // Increase font size for better visibility
          color: Colors.black, // Set text color
        ), // TextStyle
      ), // Text
    ); // Container
  }
}
