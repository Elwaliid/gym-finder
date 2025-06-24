import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_finder/model/posting_model.dart';

// ignore: must_be_immutable
class PostingExploreUI extends StatefulWidget {
  PostingModel? posting;

  PostingExploreUI({super.key, this.posting});
  @override
  State<PostingExploreUI> createState() => _PostingExploreUIUIState();
}

class _PostingExploreUIUIState extends State<PostingExploreUI> {
  PostingModel? posting;
  updateUI() async {
    setState(() {});
  }

  @override
  void initState() {
    //todo:implement initState
    super.initState();
    posting = widget.posting;
    updateUI();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 3 / 3,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
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
                      width: double.infinity,
                      height: double.infinity,
                    );
                  } catch (e) {
                    return Image.network(
                      posting!.imageNames.first.trim(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  }
                } else {
                  return Image.asset(
                    'lib/images/welcom2freeform.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            posting!.name!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2),
          child: Text(
            "${posting!.type} • ${posting!.city}, ${posting!.state}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            // Display price for first type and 1Month duration or 0 if not available
            '${posting != null && posting!.type.isNotEmpty ? (posting!.pricesPerTypeDuration[posting!.type.first]?['1Month'] ?? 0) : 0} DZD',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C9992),
            ),
          ),
        ),
      ],
    );
  }
}
