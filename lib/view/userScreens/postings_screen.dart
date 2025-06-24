// ignore_for_file: sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/model/subcripition_model.dart';
import 'package:gym_finder/view/userScreens/create_posting_screen.dart';
import 'package:gym_finder/view/widgets/postings_image_ui.dart';

class PostingsScreen extends StatefulWidget {
  const PostingsScreen({super.key});

  @override
  State<PostingsScreen> createState() => _PostingsScreen();
}

class _PostingsScreen extends State<PostingsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user's postings from Firestore
    fetchUserPostings();
  }

  Future<void> fetchUserPostings() async {
    // Refresh the user snapshot before fetching postings
    AppConstants.currentUser.snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(AppConstants.currentUser.id)
        .get();

    await AppConstants.currentUser.getMypostingFromFirestore();
    setState(() {}); // Update the UI after fetching postings
  }

  // ignore: unused_element
  Future<void> _showSubscriptionDetails(PostingModel currentPosting) async {
    QuerySnapshot subsSnapshot = await FirebaseFirestore.instance
        .collection('subscriptions')
        .where('postingId', isEqualTo: currentPosting.id)
        .get();

    List<SubscrtiptionModel> subscriptions = [];
    double totalPayments = 0;

    for (var doc in subsSnapshot.docs) {
      SubscrtiptionModel sub = SubscrtiptionModel();
      await sub.getSubscriptionInfoFromFirestoreFromPosting(
          currentPosting, doc);
      subscriptions.add(sub);
      if (sub.ammount != null) {
        totalPayments += sub.ammount!;
      }
    }

    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Subscription Statistics',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 188, 79, 46),
            ),
          ),
          // ignore: duplicate_ignore
          // ignore: sized_box_for_whitespace
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Payments: \$${totalPayments.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: subscriptions.isEmpty
                      ? Text(
                          'No subscriptions found.',
                          style: theme.textTheme.bodyMedium,
                        )
                      : Scrollbar(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: subscriptions.length,
                            itemBuilder: (context, index) {
                              final sub = subscriptions[index];
                              return ListTile(
                                title: Text(
                                  '${sub.contact?.firstName ?? ''} ${sub.contact?.lastName ?? ''}',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Amount: \$${sub.ammount?.toStringAsFixed(2) ?? '0.00'}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'Dates: ${sub.dates?.map((d) => d.toLocal().toString().split(" ")[0]).join(", ") ?? ''}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color.fromARGB(255, 188, 79, 46),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: AppConstants.currentUser.myPostings!.length + 1,
        itemBuilder: (context, index) {
          if (index == AppConstants.currentUser.myPostings!.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Get.to(CreatePostingScreen());
                  await fetchUserPostings();
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 232, 197, 145),
                        Color.fromARGB(255, 188, 79, 46),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Create New Posting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          PostingModel currentPosting =
              AppConstants.currentUser.myPostings![index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 26),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await Get.to(CreatePostingScreen(
                  posting: currentPosting,
                ));
              },
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: PostingImageUi(posting: currentPosting),
                          ),
                          if (currentPosting.isValid == false)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 128, 0)
                                      // ignore: deprecated_member_use
                                      .withOpacity(0.8),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon:
                          const Icon(Icons.more_vert, color: Colors.deepOrange),
                      onSelected: (String value) async {
                        if (value == 'view_statics') {
                          // Fetch subscriptions for the current posting
                          await currentPosting
                              .getSubscriptionsFromPostingSubcollection();

                          List<SubscrtiptionModel>? subscriptions =
                              currentPosting.subscriptions;
                          double totalPayments = 0;

                          if (subscriptions != null) {
                            for (var sub in subscriptions) {
                              if (sub.ammount != null) {
                                totalPayments += sub.ammount!;
                              }
                            }
                          }

                          // Show dialog with total payments and subscription details
                          await showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (BuildContext context) {
                              final theme = Theme.of(context);
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Subscription Statistics',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 188, 79, 46),
                                  ),
                                ),
                                content: Container(
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Total Payments: \$${totalPayments.toStringAsFixed(2)}',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: (subscriptions == null ||
                                                subscriptions.isEmpty)
                                            ? Text(
                                                'No subscriptions found.',
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              )
                                            : Scrollbar(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      subscriptions.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final sub =
                                                        subscriptions[index];
                                                    return ListTile(
                                                      title: Text(
                                                        '${sub.contact?.firstName ?? ''} ${sub.contact?.lastName ?? ''}',
                                                        style: theme.textTheme
                                                            .bodyLarge,
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Amount: \$${sub.ammount?.toStringAsFixed(2) ?? '0.00'}',
                                                            style: theme
                                                                .textTheme
                                                                .bodyMedium,
                                                          ),
                                                          Text(
                                                            'Dates: ${sub.dates?.map((d) => d.toLocal().toString().split(" ")[0]).join(", ") ?? ''}',
                                                            style: theme
                                                                .textTheme
                                                                .bodyMedium,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Close',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: const Color.fromARGB(
                                            255, 188, 79, 46),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (value == 'delete') {
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
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 188, 79, 46),
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this post?',
                                  style: theme.textTheme.bodyMedium?.copyWith(
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                    child: Text(
                                      'Delete',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
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
                            await AppConstants.currentUser
                                .removePostingfromMyPosting(currentPosting);
                            await AppConstants.postingViewModel
                                .removePosting(currentPosting);

                            await fetchUserPostings();
                            setState(() {});
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'view_statics',
                          child: Text(
                            'View Statics',
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
