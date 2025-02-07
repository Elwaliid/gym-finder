import 'package:flutter/material.dart';
import 'package:gym_finder/model/posting_model.dart';

class PostingListTileUi extends StatefulWidget {
  PostingModel? posting;

  PostingListTileUi({super.key, this.posting});

  @override
  State<StatefulWidget> createState() => _PostingListTileUiState();
}

class _PostingListTileUiState extends State<PostingListTileUi> {
  PostingModel? posting;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    posting = widget.posting;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            posting!.name!,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: AspectRatio(
          aspectRatio: 3 / 2,
          child: Image(
            image: posting!.displayImages!.first,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
