import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: unnecessary_import
import 'package:get/get_core/src/get_main.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/view/sharedScreens/view_gym_screen.dart';
import 'package:gym_finder/view/widgets/posting_explore_ui.dart';

class OnHoldScreen extends StatefulWidget {
  const OnHoldScreen({super.key});

  @override
  State<OnHoldScreen> createState() => _OnHoldScreenState();
}

class _OnHoldScreenState extends State<OnHoldScreen> {
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late FocusNode nameFocusNode;
  late FocusNode idFocusNode;

  TextEditingController controllerSearch = TextEditingController();
  TextEditingController idController = TextEditingController();

  String searchName = "";
  String searchId = "";

  Stream<QuerySnapshot> stream = FirebaseFirestore.instance
      .collection('postings')
      .where('isValid', isEqualTo: false)
      .snapshots();

  @override
  void initState() {
    super.initState();
    idFocusNode = FocusNode()..addListener(() => setState(() {}));
  }

  searchByField() {
    CollectionReference postings =
        FirebaseFirestore.instance.collection('postings');

    Query query = postings.where('isValid', isEqualTo: false);

    if (searchName.isNotEmpty) {
      query = query.where('name', isEqualTo: searchName);
    }
    if (searchId.isNotEmpty) {
      query = query.where(FieldPath.documentId, isEqualTo: searchId);
    }

    stream = query.snapshots();

    setState(() {});
  }

  Future<void> deletePostFromHostMyPostings(PostingModel posting) async {
    if (posting.host != null) {
      var hostUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(posting.host as String?)
          .get();
      if (hostUserDoc.exists) {
        try {
          List<String> myPostingIDs =
              List<String>.from(hostUserDoc['myPostingIDs'] ?? []);
          myPostingIDs.remove(posting.id);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(posting.host as String?)
              .update({
            'myPostingIDs': myPostingIDs,
          });
        } catch (e) {
          // ignore errors
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar and filter button container with shadow and rounded corners
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by Name',
                        prefixIcon:
                            Icon(Icons.search, color: Colors.deepOrange),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(
                          fontSize: 18.0, color: Colors.black87),
                      controller: controllerSearch,
                      onEditingComplete: () {
                        searchName = controllerSearch.text.trim();
                        searchByField();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune,
                        size: 30, color: Colors.deepOrange),
                    onPressed: () {
                      idController.text = searchId;

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 16,
                            child: Container(
                              width: 300,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Filter Options',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    buildCustomTextField(
                                      labelText: 'Post ID',
                                      controller: idController,
                                      focusNode: idFocusNode,
                                      onChanged: (value) {
                                        searchId = value.trim();
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepOrange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              searchByField();
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Apply'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepOrange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              searchName = "";
                                              searchId = "";
                                              controllerSearch.clear();
                                              idController.clear();
                                              searchByField();
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Clear'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepOrange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream: stream,
              builder: (context, AsyncSnapshot<QuerySnapshot> dataSnapshots) {
                if (dataSnapshots.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.deepOrange,
                  ));
                }
                if (dataSnapshots.hasError) {
                  return const Center(
                      child: Text('Error: \${dataSnapshots.error}'));
                }
                if (dataSnapshots.hasData &&
                    dataSnapshots.data!.docs.isNotEmpty) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: dataSnapshots.data!.docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 15,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      DocumentSnapshot snapshot =
                          dataSnapshots.data!.docs[index];
                      PostingModel cPosting = PostingModel(id: snapshot.id);
                      return FutureBuilder(
                        future: cPosting.getPostingInfoFromSnapshot(snapshot),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: InkResponse(
                                onTap: () {
                                  Get.to(ViewGynScreen(
                                      posting: cPosting,
                                      hostID: cPosting.host?.id));
                                },
                                enableFeedback: true,
                                child: Stack(
                                  children: [
                                    PostingExploreUI(posting: cPosting),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.check_circle,
                                            color: Colors.green),
                                        onPressed: () async {
                                          // Update isValid to true in Firestore
                                          await FirebaseFirestore.instance
                                              .collection('postings')
                                              .doc(cPosting.id)
                                              .update({'isValid': true});
                                          // Refresh the stream by calling searchByField or setState
                                          searchByField();
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () async {
                                          bool? confirmDelete =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              final theme = Theme.of(context);
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                backgroundColor: Colors.white,
                                                title: Text(
                                                  'Confirm Delete',
                                                  style: theme
                                                      .textTheme.headlineSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color.fromARGB(
                                                        255, 188, 79, 46),
                                                  ),
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete this post?',
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                actionsPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                actions: <Widget>[
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.grey[300],
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                    ),
                                                    child: Text(
                                                      'Cancel',
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255, 188, 79, 46),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                    ),
                                                    child: Text(
                                                      'Delete',
                                                      style: theme
                                                          .textTheme.bodyLarge
                                                          ?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (confirmDelete == true) {
                                            // Call removePosting and removePostingfromMyPosting
                                            await AppConstants.currentUser
                                                .deletePostFromHostMyPostings(
                                                    cPosting);
                                            await AppConstants.postingViewModel
                                                .removePosting(cPosting);

                                            setState(() {});
                                            // Refresh the stream by calling searchByField or setState
                                            searchByField();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                }
                return const Center(child: Text('No postings found'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomTextField({
    required String labelText,
    required TextEditingController controller,
    required FocusNode focusNode,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        // ignore: deprecated_member_use
        floatingLabelStyle: MaterialStateTextStyle.resolveWith(
          // ignore: deprecated_member_use
          (Set<MaterialState> states) {
            // ignore: deprecated_member_use
            if (states.contains(MaterialState.focused)) {
              return const TextStyle(
                color: Colors.deepOrange,
              );
            }
            return const TextStyle();
          },
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.deepOrange,
            width: 2.0,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
