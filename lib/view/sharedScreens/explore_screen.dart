import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/view/sharedScreens/view_gym_screen.dart';
import 'package:gym_finder/view/widgets/posting_explore_ui.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late FocusNode cityFocusNode;
  late FocusNode stateFocusNode;
  late FocusNode typeFocusNode;
  late FocusNode priceFocusNode;
  late FocusNode idFocusNode;

  TextEditingController controllerserch = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController price3MonthsController = TextEditingController();
  TextEditingController price1YearController = TextEditingController();
  TextEditingController price1SessionController = TextEditingController();
  TextEditingController idController = TextEditingController();

  String searchName = "";
  String searchCity = "";
  String searchType = "";
  String searchState = "";
  String searchPrice = "";
  String searchPrice3Months = "";
  String searchPrice1Year = "";
  String searchPrice1Session = "";
  String searchId = "";

  Stream<QuerySnapshot> stream = FirebaseFirestore.instance
      .collection('postings')
      .where('isValid', isEqualTo: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    cityFocusNode = FocusNode()..addListener(() => setState(() {}));
    stateFocusNode = FocusNode()..addListener(() => setState(() {}));
    typeFocusNode = FocusNode()..addListener(() => setState(() {}));
    priceFocusNode = FocusNode()..addListener(() => setState(() {}));
    idFocusNode = FocusNode()..addListener(() => setState(() {}));

    // Load saved postings for current user to update UI correctly
    _loadSavedPostings();
  }

  Future<void> _loadSavedPostings() async {
    await AppConstants.currentUser.fetchSavedPostingsFromFirestore();
    setState(() {});
  }

  @override
  void dispose() {
    controllerserch.dispose();
    cityController.dispose();
    stateController.dispose();
    typeController.dispose();
    priceController.dispose();
    idController.dispose();

    cityFocusNode.dispose();
    stateFocusNode.dispose();
    typeFocusNode.dispose();
    priceFocusNode.dispose();
    idFocusNode.dispose();

    super.dispose();
  }

  Future<void> searchByField() async {
    CollectionReference postings =
        FirebaseFirestore.instance.collection('postings');

    Query query = postings.where('isValid', isEqualTo: true);

    if (searchName.isNotEmpty) {
      query = query.where('name', isEqualTo: searchName);
    }
    if (searchType.isNotEmpty) {
      query = query.where('type', arrayContains: searchType);
    }
    if (searchCity.isNotEmpty) {
      query = query.where('city', isEqualTo: searchCity);
    }
    if (searchState.isNotEmpty) {
      query = query.where('state', isEqualTo: searchState);
    }
    // Helper function to parse price safely
    double? parsePrice(String priceStr) {
      try {
        return double.parse(priceStr);
      } catch (e) {
        return null;
      }
    }

    double? priceMonth = parsePrice(searchPrice);
    if (priceMonth != null) {
      query = query.where('mainPriceMonth', isEqualTo: priceMonth);
    }

    double? price3Months = parsePrice(searchPrice3Months);
    if (price3Months != null) {
      query = query.where('mainPrice3Months', isEqualTo: price3Months);
    }

    double? price1Year = parsePrice(searchPrice1Year);
    if (price1Year != null) {
      query = query.where('mainPrice1Year', isEqualTo: price1Year);
    }

    double? price1Session = parsePrice(searchPrice1Session);
    if (price1Session != null) {
      query = query.where('mainPrice1Session', isEqualTo: price1Session);
    }

    if (searchId.isNotEmpty) {
      query = query.where(FieldPath.documentId, isEqualTo: searchId);
    }
    stream = query.snapshots();

    setState(() {});
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
                        hintText: 'Search',
                        prefixIcon:
                            Icon(Icons.search, color: Colors.deepOrange),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(
                          fontSize: 18.0, color: Colors.black87),
                      controller: controllerserch,
                      onEditingComplete: () {
                        searchName = controllerserch.text.trim();
                        searchByField();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune,
                        size: 30, color: Colors.deepOrange),
                    onPressed: () {
                      cityController.text = searchCity;
                      stateController.text = searchState;
                      typeController.text = searchType;
                      priceController.text = searchPrice;
                      price3MonthsController.text = searchPrice3Months;
                      price1YearController.text = searchPrice1Year;
                      price1SessionController.text = searchPrice1Session;
                      idController.text = searchId;

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          bool localShowAdditionalPrices = false;
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
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
                                          labelText: 'City',
                                          controller: cityController,
                                          focusNode: cityFocusNode,
                                          onChanged: (value) {
                                            searchCity = value.trim();
                                          },
                                        ),
                                        const SizedBox(height: 15),
                                        buildCustomTextField(
                                          labelText: 'State',
                                          controller: stateController,
                                          focusNode: stateFocusNode,
                                          onChanged: (value) {
                                            searchState = value.trim();
                                          },
                                        ),
                                        const SizedBox(height: 15),
                                        buildCustomTextField(
                                          labelText: 'Sport',
                                          controller: typeController,
                                          focusNode: typeFocusNode,
                                          onChanged: (value) {
                                            searchType = value.trim();
                                          },
                                        ),
                                        const SizedBox(height: 15),
                                        if ((AppConstants.currentUser.isAdmin ??
                                            false)) ...[
                                          buildCustomTextField(
                                            labelText: 'Post ID',
                                            controller: idController,
                                            focusNode: idFocusNode,
                                            onChanged: (value) {
                                              searchId = value.trim();
                                            },
                                          ),
                                          const SizedBox(height: 15),
                                        ],
                                        buildCustomTextField(
                                          labelText: 'Price of 1 Month',
                                          controller: priceController,
                                          focusNode: priceFocusNode,
                                          onChanged: (value) {
                                            searchPrice = value.trim();
                                          },
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              localShowAdditionalPrices
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: Colors.deepOrange,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                localShowAdditionalPrices =
                                                    !localShowAdditionalPrices;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        if (localShowAdditionalPrices) ...[
                                          const SizedBox(height: 15),
                                          buildCustomTextField(
                                            labelText: 'Price of 3 Months',
                                            controller: price3MonthsController,
                                            focusNode: FocusNode(),
                                            onChanged: (value) {
                                              searchPrice3Months = value.trim();
                                            },
                                          ),
                                          const SizedBox(height: 15),
                                          buildCustomTextField(
                                            labelText: 'Price of 1 Year',
                                            controller: price1YearController,
                                            focusNode: FocusNode(),
                                            onChanged: (value) {
                                              searchPrice1Year = value.trim();
                                            },
                                          ),
                                          const SizedBox(height: 15),
                                          buildCustomTextField(
                                            labelText: 'Price of 1 Session',
                                            controller: price1SessionController,
                                            focusNode: FocusNode(),
                                            onChanged: (value) {
                                              searchPrice1Session =
                                                  value.trim();
                                            },
                                          ),
                                          const SizedBox(height: 15),
                                        ],
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepOrange,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12),
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
                                                backgroundColor:
                                                    Colors.deepOrange,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  searchName = "";
                                                  searchCity = "";
                                                  searchType = "";
                                                  searchState = "";
                                                  searchPrice = "";
                                                  searchPrice3Months = "";
                                                  searchPrice1Year = "";
                                                  searchPrice1Session = "";
                                                  searchId = "";
                                                  cityController.clear();
                                                  stateController.clear();
                                                  typeController.clear();
                                                  priceController.clear();
                                                  price3MonthsController
                                                      .clear();
                                                  price1YearController.clear();
                                                  price1SessionController
                                                      .clear();
                                                  idController.clear();
                                                  searchByField();
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Clear'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepOrange,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12),
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
                  return const SizedBox.shrink();
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
                                      right: 8,
                                      child: StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          bool isSaved = AppConstants
                                              .currentUser.savedPostings!
                                              .any((posting) =>
                                                  posting.id == cPosting.id);
                                          return IconButton(
                                            icon: Icon(
                                              isSaved
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isSaved
                                                  ? Colors.deepOrange
                                                  : const Color.fromARGB(
                                                      255, 54, 53, 53),
                                            ),
                                            onPressed: () async {
                                              if (isSaved) {
                                                await AppConstants.currentUser
                                                    .removeSavedPosting(
                                                        cPosting);
                                              } else {
                                                await AppConstants.currentUser
                                                    .addSavedPosting(cPosting);
                                              }
                                              setState(() {});
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 40,
                                      child: (AppConstants
                                                  .currentUser.isAdmin ??
                                              false)
                                          ? IconButton(
                                              icon: const Icon(Icons.close,
                                                  color: Colors.red),
                                              onPressed: () async {
                                                bool? confirmDelete =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    final theme =
                                                        Theme.of(context);
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: Text(
                                                        'Confirm Delete',
                                                        style: theme.textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 188, 79, 46),
                                                        ),
                                                      ),
                                                      content: Text(
                                                        'Are you sure you want to delete this post?',
                                                        style: theme.textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                      ),
                                                      actionsPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16,
                                                              vertical: 8),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[300],
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                          ),
                                                          child: Text(
                                                            'Cancel',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color: Colors
                                                                  .black87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                        ),
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    188,
                                                                    79,
                                                                    46),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                          ),
                                                          child: Text(
                                                            'Delete',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
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
                                                  await AppConstants
                                                      .postingViewModel
                                                      .removePosting(cPosting);

                                                  setState(() {});

                                                  // Refresh the stream by calling searchByField or setState
                                                  searchByField();
                                                }
                                              },
                                            )
                                          : const SizedBox.shrink(),
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
    Widget? suffixIcon,
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
        suffixIcon: suffixIcon,
      ),
      onChanged: onChanged,
    );
  }
}
