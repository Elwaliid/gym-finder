import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_finder/model/contact_model.dart';
import 'package:gym_finder/model/posting_model.dart';

class SubscrtiptionModel {
  String id = "";
  PostingModel? posting;
  ContactModel? contact;
  List<DateTime>? dates;
  String? userId;
  double? ammount;
  SubscrtiptionModel();
  Future<void> getSubscriptionInfoFromFirestoreFromPosting(
      PostingModel posting, DocumentSnapshot snapshot) async {
    this.posting = posting;
    List<Timestamp> timestamps = List<Timestamp>.from(snapshot['dates']);
    dates = [];
    // ignore: avoid_function_literals_in_foreach_calls
    timestamps.forEach((timestamp) {
      dates!.add((timestamp.toDate()));
    });
    String contactID = snapshot['UserID'] ?? "";
    String fullName = snapshot['name'] ?? "";
    _loadContactInfo(contactID, fullName);
    ammount = (snapshot['ammount'] != null)
        ? (snapshot['ammount'] as num).toDouble()
        : null;
  }

  getSubscriptionInfoFromFirestoresFromPosting(
      PostingModel posting, DocumentSnapshot snapshot) async {
    posting = posting;
    List<Timestamp> timestamps = List<Timestamp>.from(snapshot['dates']);
    dates = [];
    // ignore: avoid_function_literals_in_foreach_calls
    timestamps.forEach((timestamp) {
      dates!.add((timestamp.toDate()));
    });
    String contactID = snapshot['UserID'] ?? "";
    String fullName = snapshot['name'] ?? "";
    _loadContactInfo(id, fullName);
    contact = ContactModel(id: contactID);
    ammount = (snapshot['ammount'] != null)
        ? (snapshot['ammount'] as num).toDouble()
        : null;
  }

  _loadContactInfo(String id, String fullName) {
    String firstName = "";
    String lastName = "";
    firstName = fullName.split(" ")[0];
    lastName = fullName.split(" ")[1];
    contact = ContactModel(id: id, firstName: firstName, lastName: lastName);
  }

  createSubscription(
      PostingModel postingM, ContactModel contactM, List<DateTime> datesM) {
    posting = postingM;
    contact = contactM;
    dates = datesM;
    dates!.sort();
  }

  Future<void> updateSubscriptionInFirestore() async {
    if (id.isEmpty || dates == null) return;

    // Convert dates to Firestore Timestamps
    List<Timestamp> timestamps =
        dates!.map((date) => Timestamp.fromDate(date)).toList();

    await FirebaseFirestore.instance
        .collection('subscriptions')
        .doc(id)
        .update({
      'dates': timestamps,
    });
  }
}
