// ignore_for_file: unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: unnecessary_import
import 'package:get/get_core/src/get_main.dart';
import 'package:gym_finder/global.dart';
import 'package:gym_finder/model/app_constants.dart';

import 'package:gym_finder/model/subcripition_model.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/view/adminScreens/admin_home_screen.dart';
import 'package:gym_finder/view/userScreens/user_home_screen.dart';

import 'package:gym_finder/view/widgets/calender_ui.dart';

// ignore: must_be_immutable
class SessionPaymentScreen extends StatefulWidget {
  final List<String>? selectedSports;
  PostingModel? posting;
  String? hostID;
  SubscrtiptionModel? subscription;
  SessionPaymentScreen({
    super.key,
    this.selectedSports,
    this.posting,
    this.hostID,
    this.subscription,
  });

  @override
  State<SessionPaymentScreen> createState() => _SessionPaymentScreenState();
}

class _SessionPaymentScreenState extends State<SessionPaymentScreen> {
  PostingModel? posting;
  List<DateTime> subscribedDates = [];
  List<DateTime> selectedDates = [];
  List<CalenderUI> calenderWidgets = [];

  _buildCalendarWidgets() {
    for (int i = 0; i < 12; i++) {
      calenderWidgets.add(
        CalenderUI(
          monthIndex: i,
          subscribedDates: subscribedDates,
          selectDate: _selectDate,
          getSelectedDates: _getSelectedDates,
        ),
      );
      setState(() {});
    }
  }

  List<DateTime> _getSelectedDates() {
    return selectedDates;
  }

  _selectDate(DateTime date) {
    if (selectedDates.contains(date)) {
      selectedDates.remove(date);
    } else {
      selectedDates.add(date);
    }
    selectedDates.sort();
    setState(() {});
  }

  _loadSubscribedDates() async {
    subscribedDates = [];
    if (posting == null) {
      _buildCalendarWidgets();
      return;
    }
    try {
      var subscriptionsSnapshot = await FirebaseFirestore.instance
          .collection('postings')
          .doc(posting!.id)
          .collection('subscriptions')
          .where('UserID', isEqualTo: AppConstants.currentUser.id)
          .get();

      for (var doc in subscriptionsSnapshot.docs) {
        List<dynamic>? datesList = doc['dates'];
        if (datesList == null || datesList.isEmpty) {
          continue;
        }
        for (var d in datesList) {
          DateTime date = d is Timestamp
              ? d.toDate()
              : DateTime.parse(d.toString());
          if (!subscribedDates.contains(date)) {
            subscribedDates.add(date);
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading subscribed dates: $e');
    }
    _buildCalendarWidgets();
  }

  void _makeSessionSubscription(List<String> selectedSports) {
    if (selectedDates.isEmpty) {
      return;
    }
    // Calculate total price for sessions of selected sports multiplied by number of dates
    double totalPrice = 0;
    int numberOfDates = selectedDates.length;
    for (var sport in selectedSports) {
      totalPrice += posting!.pricesPerTypeDuration[sport]?['1Session'] ?? 0;
    }
    totalPrice *= numberOfDates;

    posting!
        .makenewSubscriptionWithPrice(
          selectedDates,
          context,
          widget.hostID,
          totalPrice,
        )
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

  _makeSubscription() {
    if (selectedDates.isEmpty) {
      return;
    }
    posting!
        .makenewSubscription(selectedDates, context, widget.hostID)
        .whenComplete(() {
          Get.back();
        });
  }

  @override
  void initState() {
    super.initState();
    posting = widget.posting;

    if (widget.subscription != null && widget.subscription!.dates != null) {
      selectedDates = List.from(widget.subscription!.dates!);
    }

    _loadSubscribedDates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        title: Text(
          "Subscribe in ${posting!.name}'s gym",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80, bottom: 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Calendar header row with days
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Sun'),
                    Text('Mon'),
                    Text('Tue'),
                    Text('Wed'),
                    Text('Thu'),
                    Text('Fri'),
                    Text('Sat'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: calenderWidgets.isEmpty
                      ? Container()
                      : PageView.builder(
                          itemCount: calenderWidgets.length,
                          itemBuilder: (context, index) {
                            return calenderWidgets[index];
                          },
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: subPrice == 0.0
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 232, 197, 145),
                            Color.fromARGB(255, 188, 79, 46),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          if (widget.selectedSports != null) {
                            _makeSessionSubscription(widget.selectedSports!);
                          }
                        },
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Proceed',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
