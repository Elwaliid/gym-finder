import 'package:flutter/material.dart';

class PostingListTileButton extends StatelessWidget {
  const PostingListTileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height:
          screenHeight * 0.118, // Using a decimal value for better readability
      width: screenWidth, // Set the width to match the screen width
      child: const Padding(
        padding: EdgeInsets.fromLTRB(26, 0, 26, 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add),
            Text(
              'Create a listing',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
