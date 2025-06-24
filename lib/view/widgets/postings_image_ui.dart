// ignore_for_file: sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_finder/model/posting_model.dart';

// ignore: must_be_immutable
class PostingImageUi extends StatefulWidget {
  PostingModel? posting;

  PostingImageUi({super.key, this.posting});

  @override
  State<StatefulWidget> createState() => _PostingImageUiState();
}

class _PostingImageUiState extends State<PostingImageUi> {
  PostingModel? posting;

  @override
  void initState() {
    super.initState();
    posting = widget.posting;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        height: 200,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 40),
              child: SizedBox(
                width: 150,
                child: Text(
                  posting!.name!,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 190,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Make image round
                child: Builder(
                  builder: (context) {
                    if (posting != null &&
                        posting!.imageNames.isNotEmpty &&
                        posting!.imageNames.first.trim().isNotEmpty) {
                      try {
                        final decodedBytes =
                            base64Decode(posting!.imageNames.first.trim());
                        return Image.memory(
                          decodedBytes,
                          fit: BoxFit.cover,
                        );
                      } catch (e) {
                        // If decoding fails, fallback to network image
                        return Image.network(
                          posting!.imageNames.first.trim(),
                          fit: BoxFit.cover,
                        );
                      }
                    } else {
                      return Image.asset(
                        'lib/images/welcom2freeform.jpg',
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
