// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:flutter/material.dart';
import 'package:gym_finder/view/adminScreens/admin_home_screen.dart';
import 'package:gym_finder/view/sharedScreens/session_payment_screen.dart';
import 'package:gym_finder/view/userScreens/user_home_screen.dart';
import 'package:intl/intl.dart' as intl;

class ViewGynScreen extends StatefulWidget {
  final PostingModel? posting;
  final String? hostID;
  const ViewGynScreen({super.key, this.posting, this.hostID});

  @override
  State<ViewGynScreen> createState() => _ViewGynScreenState();
}

class _ViewGynScreenState extends State<ViewGynScreen> {
  late PostingModel? posting;
  String imageFileOfUser = "";
  late PageController _pageController;

  String calculateDateRange() {
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(const Duration(days: 30));
    String formattedStartDate =
        intl.DateFormat('MMMM d, yyyy').format(startDate);
    String formattedEndDate = intl.DateFormat('MMMM d, yyyy').format(endDate);
    return '$formattedStartDate - $formattedEndDate';
  }

  String calculateThreeMonthDateRange() {
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(const Duration(days: 90));
    String formattedStartDate =
        intl.DateFormat('MMMM d, yyyy').format(startDate);
    String formattedEndDate = intl.DateFormat('MMMM d, yyyy').format(endDate);
    return '$formattedStartDate - $formattedEndDate';
  }

  String calculateOneYearDateRange() {
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(const Duration(days: 365));
    String formattedStartDate =
        intl.DateFormat('MMMM d, yyyy').format(startDate);
    String formattedEndDate = intl.DateFormat('MMMM d, yyyy').format(endDate);
    return '$formattedStartDate - $formattedEndDate';
  }

  void _makeSubscription(String dateRange, List<String> selectedSports) async {
    List<DateTime> dates = [];
    List<String> dateParts = dateRange.split(' - ');
    if (dateParts.length == 2) {
      DateTime startDate = intl.DateFormat('MMMM d, yyyy').parse(dateParts[0]);
      DateTime endDate = intl.DateFormat('MMMM d, yyyy').parse(dateParts[1]);
      dates = [startDate, endDate];
    }

    // Calculate total price for selected sports according to duration
    double totalPrice = 0;
    String durationKey = '';
    if (dateRange == calculateDateRange()) {
      durationKey = '1Month';
    } else if (dateRange == calculateThreeMonthDateRange()) {
      durationKey = '3Months';
    } else if (dateRange == calculateOneYearDateRange()) {
      durationKey = '1Year';
    }

    for (var sport in selectedSports) {
      totalPrice += posting!.pricesPerTypeDuration[sport]?[durationKey] ?? 0;
    }

    posting!
        .makenewSubscriptionWithPrice(dates, context, widget.hostID, totalPrice)
        .whenComplete(() {
      bool isAdmin = AppConstants.currentUser.isAdmin ?? false;
      if (isAdmin == false) {
        Get.to(() => const UserScreen());
      } else {
        Get.to(() => const AdminScreen());
      }
      Get.snackbar("Success", "subscription made successfully");
    });
  }

  @override
  void initState() {
    super.initState();
    posting = widget.posting;
    _pageController = PageController(initialPage: 0);
    _fetchHostProfileImage();
  }

  Future<void> _fetchHostProfileImage() async {
    try {
      final hostId = widget.hostID;
      print('Fetching profile image for hostId: $hostId');
      if (hostId != null && hostId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(hostId)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('profileImageData')) {
            String? profileImageData = data['profileImageData'];
            print(
                'Fetched profileImageData length: ${profileImageData?.length}');
            if (profileImageData != null && profileImageData.isNotEmpty) {
              setState(() {
                imageFileOfUser = profileImageData;
              });
            }
          } else {
            print('No profileImageData found in user document');
          }
        } else {
          print('User document does not exist for hostId: $hostId');
        }
      } else {
        print('hostId is null or empty');
      }
    } catch (e) {
      print('Error fetching host profile image: $e');
    }
  }

  final BoxDecoration _buttonBoxDecoration = const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 232, 197, 145),
        Color.fromARGB(255, 188, 79, 46),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(30)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );

  final BoxDecoration _buttonBoxDecorationFaded = const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 232, 197, 145),
        Color.fromARGB(255, 188, 79, 46),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(30)),
    boxShadow: [
      BoxShadow(
        color: Color.fromARGB(177, 255, 166, 94),
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );

  Widget _buildSubscriptionButton(String text, VoidCallback onPressed,
      {bool faded = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: faded ? _buttonBoxDecorationFaded : _buttonBoxDecoration,
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<String> selectedSports = [];
    Map<String, double> prices = {
      '1Month': 0,
      '3Months': 0,
      '1Year': 0,
      'session': 0,
    };

    void updatePrices(List<String> selectedSports) {
      prices = {
        '1Month': 0,
        '3Months': 0,
        '1Year': 0,
        'session': 0,
      };
      for (var sport in selectedSports) {
        prices['1Month'] = prices['1Month']! +
            (posting!.pricesPerTypeDuration[sport]?['1Month'] ?? 0);
        prices['3Months'] = prices['3Months']! +
            (posting!.pricesPerTypeDuration[sport]?['3Months'] ?? 0);
        prices['1Year'] = prices['1Year']! +
            (posting!.pricesPerTypeDuration[sport]?['1Year'] ?? 0);
        prices['session'] = prices['session']! +
            (posting!.pricesPerTypeDuration[sport]?['1Session'] ?? 0);
      }
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 188, 79, 46),
                Color.fromARGB(255, 232, 197, 145),
              ],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          'Posting Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: (posting != null && posting!.imageNames.isNotEmpty)
                        ? SizedBox(
                            height: MediaQuery.of(context).size.width * 2 / 3,
                            child: Listener(
                              onPointerSignal: (pointerSignal) {
                                if (pointerSignal is PointerScrollEvent) {
                                  if (pointerSignal.scrollDelta.dy > 0) {
                                    _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  } else if (pointerSignal.scrollDelta.dy < 0) {
                                    _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                }
                              },
                              child: GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  if (details.delta.dx < 0) {
                                    _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  } else if (details.delta.dx > 0) {
                                    _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                },
                                child: PageView.builder(
                                  controller: _pageController,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: posting!.imageNames.length,
                                  itemBuilder: (context, index) {
                                    final imageString =
                                        posting!.imageNames[index].trim();
                                    try {
                                      final decodedBytes =
                                          base64Decode(imageString);
                                      return Image.memory(
                                        decodedBytes,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    } catch (e) {
                                      return Image.network(
                                        imageString,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            'lib/images/welcom2freeform.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleSelectableText(
                      posting?.name?.toUpperCase() ?? '',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 3,
                      scrollPhysics: const ClampingScrollPhysics(),
                      onSelectionChanged: null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Container(
                        decoration: _buttonBoxDecoration,
                        child: MaterialButton(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 32.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          onPressed: () async {
                            int alreadySubscribed = 0;

                            DateTime now = DateTime.now();
                            var subscriptionsSnapshot = await FirebaseFirestore
                                .instance
                                .collection('postings')
                                .doc(posting?.id)
                                .collection('subscriptions')
                                .where('UserID',
                                    isEqualTo: AppConstants.currentUser.id)
                                .get();

                            for (var doc in subscriptionsSnapshot.docs) {
                              List<dynamic>? datesList = doc['dates'];
                              if (datesList == null || datesList.isEmpty) {
                                continue;
                              }
                              DateTime maxDate = datesList
                                  .map((d) => d is Timestamp
                                      ? d.toDate()
                                      : DateTime.parse(d.toString()))
                                  .reduce((a, b) => a.isAfter(b) ? a : b);

                              bool allSameMonth = datesList.every((d) {
                                DateTime date = d is Timestamp
                                    ? d.toDate()
                                    : DateTime.parse(d.toString());
                                return date.month == maxDate.month &&
                                    date.year == maxDate.year;
                              });

                              if (datesList.length == 2) {
                                DateTime firstDate = datesList[0] is Timestamp
                                    ? datesList[0].toDate()
                                    : DateTime.parse(datesList[0].toString());
                                DateTime secondDate = datesList[1] is Timestamp
                                    ? datesList[1].toDate()
                                    : DateTime.parse(datesList[1].toString());
                                if (now.isBefore(maxDate) &&
                                    !(firstDate.month == secondDate.month &&
                                        firstDate.year == secondDate.year)) {
                                  alreadySubscribed = 1;
                                  break;
                                }
                                if (firstDate.month == secondDate.month &&
                                    firstDate.year == secondDate.year) {
                                  continue;
                                }
                              } else {
                                // length != 2
                                if (allSameMonth) {
                                  continue;
                                } else if (!allSameMonth &&
                                    now.isBefore(maxDate)) {
                                  alreadySubscribed = 1;
                                  break;
                                }
                              }
                            }
                            if (posting!.getPlacesAvailable() == 0) {
                              alreadySubscribed = 2;
                            }
                            if (alreadySubscribed == 1) {
                              Get.snackbar("Subscription Exists",
                                  "You have already Subscribed this posting.");
                              return;
                            }
                            if (alreadySubscribed == 2) {
                              Get.snackbar("Gym is full",
                                  "No more places available for now");
                              return;
                            }
                            updatePrices(selectedSports);
                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    void updateSelectedSports(
                                        bool selected, String sport) {
                                      if (selected) {
                                        selectedSports.add(sport);
                                      } else {
                                        selectedSports.remove(sport);
                                      }
                                      updatePrices(selectedSports);
                                      setState(() {});
                                    }

                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Select Sports',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 188, 79, 46),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 8,
                                            children: posting?.type
                                                    .map((sport) {
                                                  final bool isSelected =
                                                      selectedSports
                                                          .contains(sport);
                                                  return ChoiceChip(
                                                    label: Text(sport),
                                                    selected: isSelected,
                                                    selectedColor:
                                                        const Color.fromARGB(
                                                            255, 188, 79, 46),
                                                    labelStyle: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                    onSelected: (selected) {
                                                      updateSelectedSports(
                                                          selected, sport);
                                                    },
                                                  );
                                                }).toList() ??
                                                [],
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            'Prices:',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 188, 79, 46),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Month:',
                                                        style: theme.textTheme
                                                            .titleMedium),
                                                    Text(
                                                        '${prices['1Month']?.toStringAsFixed(2) ?? '0'} DZD',
                                                        style: theme.textTheme
                                                            .titleMedium),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('3 Months:',
                                                        style: theme.textTheme
                                                            .titleMedium),
                                                    Text(
                                                        '${prices['3Months']?.toStringAsFixed(2) ?? '0'} DZD',
                                                        style: theme.textTheme
                                                            .titleMedium),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('1 Year:',
                                                        style: theme.textTheme
                                                            .titleMedium),
                                                    Text(
                                                        '${prices['1Year']?.toStringAsFixed(2) ?? '0'} DZD',
                                                        style: theme.textTheme
                                                            .titleMedium),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('1 Session:',
                                                        style: theme.textTheme
                                                            .titleMedium),
                                                    Text(
                                                        '${prices['session']?.toStringAsFixed(2) ?? '0'} DZD',
                                                        style: theme.textTheme
                                                            .titleMedium),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            'Select subscription Duration',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 188, 79, 46),
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: [
                                            _buildSubscriptionButton('1 Month',
                                                () {
                                              String dateRange =
                                                  calculateDateRange();
                                              if (selectedSports.isEmpty) {
                                                Get.snackbar(
                                                  "Selection Required",
                                                  "Please pick at least one sport.",
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.white,
                                                  colorText: Colors.black,
                                                );
                                                return;
                                              }
                                              _makeSubscription(
                                                  dateRange, selectedSports);
                                              Navigator.of(context).pop();
                                            }),
                                            _buildSubscriptionButton('3 Months',
                                                () {
                                              String dateRange =
                                                  calculateThreeMonthDateRange();
                                              if (selectedSports.isEmpty) {
                                                Get.snackbar(
                                                  "Selection Required",
                                                  "Please pick at least one sport.",
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.white,
                                                  colorText: Colors.black,
                                                );
                                                return;
                                              }
                                              _makeSubscription(
                                                  dateRange, selectedSports);
                                              Navigator.of(context).pop();
                                            }, faded: true),
                                            _buildSubscriptionButton('1 Year',
                                                () {
                                              String dateRange =
                                                  calculateOneYearDateRange();
                                              if (selectedSports.isEmpty) {
                                                Get.snackbar(
                                                  "Selection Required",
                                                  "Please pick at least one sport.",
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.white,
                                                  colorText: Colors.black,
                                                );
                                                return;
                                              }
                                              _makeSubscription(
                                                  dateRange, selectedSports);
                                              Navigator.of(context).pop();
                                            }),
                                            _buildSubscriptionButton('SESSION',
                                                () {
                                              if (selectedSports.isEmpty) {
                                                Get.snackbar(
                                                  "Selection Required",
                                                  "Please pick at least one sport.",
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.white,
                                                  colorText: Colors.black,
                                                );
                                                return;
                                              }
                                              Navigator.of(context).pop();
                                              Get.to(SessionPaymentScreen(
                                                selectedSports: selectedSports,
                                                posting: posting,
                                                hostID: widget.hostID,
                                              ));
                                            }),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Subscribe Now',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        // Display price for first type and 1Month duration or 0 if not available
                        '${posting != null && posting!.type.isNotEmpty ? (posting!.pricesPerTypeDuration[posting!.type.first]?['1Month'] ?? 0) : 0} DZD / month',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleSelectableText(
                        posting?.getFullAddress() ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange[800],
                        ),
                        onSelectionChanged: null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 12.5,
                          backgroundImage: imageFileOfUser.isNotEmpty
                              ? MemoryImage(base64Decode(imageFileOfUser))
                              : const AssetImage('lib/images/avatar.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          posting?.host?.getFullNameOfUser() ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 11.0, left: 20.0),
                            child: Icon(Icons.phone,
                                color: Color.fromARGB(255, 55, 54, 54)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: SingleSelectableText(
                                (posting?.phone != null && posting!.phone != "")
                                    ? posting!.phone!
                                    : 'N/A',
                                style: const TextStyle(fontSize: 20),
                                onSelectionChanged: null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 11.0, left: 20.0),
                            child: Icon(Icons.email,
                                color: Color.fromARGB(255, 55, 54, 54)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: SingleSelectableText(
                                posting?.email ?? 'N/A',
                                style: const TextStyle(fontSize: 20),
                                onSelectionChanged: null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.person_add,
                          size: 30,
                        ),
                        subtitle: Text(
                          '${posting!.getPlacesAvailable()} places available',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Description',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleSelectableText(
                  posting?.description ?? '',
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                  onSelectionChanged: null,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class SingleSelectableText extends StatefulWidget {
  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextHeightBehavior? textHeightBehavior;
  final TextWidthBasis? textWidthBasis;
  final TextSelectionControls? selectionControls;
  final ScrollPhysics? scrollPhysics;
  final void Function()? onSelectionChanged;
  final void Function()? onTap;

  // ignore: use_super_parameters
  const SingleSelectableText(
    this.data, {
    Key? key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.textDirection,
    this.textHeightBehavior,
    this.textWidthBasis,
    this.selectionControls,
    this.scrollPhysics,
    this.onSelectionChanged,
    this.onTap,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SingleSelectableTextState createState() => _SingleSelectableTextState();
}

class _SingleSelectableTextState extends State<SingleSelectableText> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.onSelectionChanged?.call();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        _focusNode.requestFocus();
      },
      child: Focus(
        focusNode: _focusNode,
        child: SelectableText(
          widget.data,
          style: widget.style,
          maxLines: widget.maxLines,
          textAlign: widget.textAlign ?? TextAlign.start,
          textDirection: widget.textDirection,
          textHeightBehavior: widget.textHeightBehavior,
          textWidthBasis: widget.textWidthBasis ?? TextWidthBasis.parent,
          selectionControls: widget.selectionControls,
          scrollPhysics: widget.scrollPhysics,
          onSelectionChanged: (selection, cause) {
            if (_focusNode.hasFocus) {
              widget.onSelectionChanged?.call();
            }
          },
        ),
      ),
    );
  }
}
