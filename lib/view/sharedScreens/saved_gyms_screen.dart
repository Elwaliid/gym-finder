// ignore_for_file: unnecessary_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/view/sharedScreens/view_gym_screen.dart';
import 'package:gym_finder/view/widgets/posting_explore_ui.dart';

class SavedGymsScreen extends StatefulWidget {
  const SavedGymsScreen({super.key});

  @override
  State<SavedGymsScreen> createState() => _SavedGymsScreen();
}

class _SavedGymsScreen extends State<SavedGymsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh the user snapshot before fetching saved postings
    AppConstants.currentUser.snapshot = null;
    FirebaseFirestore.instance
        .collection('users')
        .doc(AppConstants.currentUser.id)
        .get()
        .then((snapshot) {
      AppConstants.currentUser.snapshot = snapshot;
      AppConstants.currentUser.fetchSavedPostingsFromFirestore().then((_) {
        setState(() {}); // Update the UI after fetching saved postings
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        // Removed NeverScrollableScrollPhysics to enable scrolling
        shrinkWrap: true,
        padding: const EdgeInsets.all(12),
        itemCount: AppConstants.currentUser.savedPostings!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 15,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          PostingModel currentPosting =
              AppConstants.currentUser.savedPostings![index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                InkResponse(
                  onTap: () {
                    Get.to(ViewGynScreen(
                        posting: currentPosting,
                        hostID: currentPosting.host?.id ?? ''));
                  },
                  enableFeedback: true,
                  child: PostingExploreUI(
                    posting: currentPosting,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      bool isSaved = AppConstants.currentUser.savedPostings!
                          .any((posting) => posting.id == currentPosting.id);
                      return IconButton(
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved
                              ? Colors.deepOrange
                              : const Color.fromARGB(255, 54, 53, 53),
                        ),
                        onPressed: () async {
                          if (isSaved) {
                            await AppConstants.currentUser
                                .removeSavedPosting(currentPosting);
                          } else {
                            await AppConstants.currentUser
                                .addSavedPosting(currentPosting);
                          }
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
