// ignore_for_file: unnecessary_import, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/subcripition_model.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/view/sharedScreens/view_gym_screen.dart';
import 'package:gym_finder/view/widgets/posting_explore_ui.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'subscribed_dates_dialog.dart';

// ignore: must_be_immutable
class SubscriptionsScreen extends StatefulWidget {
  PostingModel? posting;
  SubscriptionsScreen({super.key, this.posting});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreen();
}

class _SubscriptionsScreen extends State<SubscriptionsScreen> {
  PostingModel? posting;
  Stream<QuerySnapshot> stream =
      FirebaseFirestore.instance.collection('postings').snapshots();

  @override
  void initState() {
    super.initState();
    AppConstants.currentUser.snapshot = null;
    FirebaseFirestore.instance
        .collection('users')
        .doc(AppConstants.currentUser.id)
        .get()
        .then((snapshot) {
      AppConstants.currentUser.snapshot = snapshot;
      fetchsubscriptionsFromFirestore();
    });
  }

  Future<void> fetchsubscriptionsFromFirestore() async {
    await AppConstants.currentUser.getSubscribedPostingsFromFirestore();

    // Parallelize fetching subscriptions for each posting
    List<Future> futures = [];
    for (var posting in AppConstants.currentUser.savedsubscriptions!) {
      futures.add(Future(() async {
        final subscriptionDocs = await FirebaseFirestore.instance
            .collection('postings')
            .doc(posting.id)
            .collection('subscriptions')
            .where('UserID', isEqualTo: AppConstants.currentUser.id)
            .get();

        List<String> allDates = [];

        posting.subscriptions = [];

        for (var doc in subscriptionDocs.docs) {
          List<dynamic> timestamps = doc['dates'];
          for (var ts in timestamps) {
            if (ts is Timestamp) {
              final dateStr = DateFormat('dd MMM yyyy').format(ts.toDate());
              allDates.add(dateStr);
            }
          }
          SubscrtiptionModel subscription = SubscrtiptionModel();
          await subscription.getSubscriptionInfoFromFirestoresFromPosting(
              posting, doc);
          posting.subscriptions!.add(subscription);
        }

        posting.subscribedDates = allDates;
      }));
    }
    await Future.wait(futures);

    // Delay setState to batch UI update after all fetches complete
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a list of unique postings by id to avoid duplicates
    final uniquePostingsMap = <String, PostingModel>{};
    for (var posting in AppConstants.currentUser.savedsubscriptions!) {
      if (posting.id != null && !uniquePostingsMap.containsKey(posting.id)) {
        uniquePostingsMap[posting.id!] = posting;
      }
    }
    final uniquePostings = uniquePostingsMap.values.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: uniquePostings.length,
        itemBuilder: (context, index) {
          final posting = uniquePostings[index];
          final screenWidth = MediaQuery.of(context).size.width;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                shadowColor: Colors.black26,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Get.to(ViewGynScreen(
                        posting: posting, hostID: posting.host?.id));
                  },
                  child: Container(
                    width: screenWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        PostingExploreUI(posting: posting),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkResponse(
                            radius: 24,
                            onTap: () async {
                              bool? confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  final theme = Theme.of(context);
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: Colors.white,
                                    title: Text(
                                      'Confirm Delete',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                            255, 188, 79, 46),
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this subscription?',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    actionsPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    actions: <Widget>[
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 188, 79, 46),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                        ),
                                        child: Text(
                                          'Delete',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmDelete == true) {
                                AppConstants.currentUser
                                    .removeSubscriptionPostingFromFirestoreUser(
                                        posting);
                                AppConstants.currentUser
                                    .removeSubscriptionFromFirestorePost(
                                        posting);
                                setState(() {
                                  fetchsubscriptionsFromFirestore();
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Color.fromARGB(255, 21, 21, 21),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Tooltip(
                                message: 'View Subscribed dates',
                                child: IconButton(
                                  icon: const Icon(Icons.calendar_today,
                                      size: 20),
                                  onPressed: () {
                                    if (posting.subscribedDates?.isNotEmpty ??
                                        false) {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            SubscribedDatesDialog(
                                          subscribedDates:
                                              posting.subscribedDates!,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Paid: ${posting.subscriptions != null && posting.subscriptions!.isNotEmpty ? posting.subscriptions!.map((b) => b.ammount ?? 0).toString() : 'N/A'} DZD',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF3C9992),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
