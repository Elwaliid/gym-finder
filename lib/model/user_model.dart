// ignore_for_file: avoid_function_literals_in_foreach_calls, duplicate_ignore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
// ignore: unnecessary_import
import 'package:get/get_core/src/get_main.dart';

import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/subcripition_model.dart';
import 'package:gym_finder/model/contact_model.dart';
import 'package:gym_finder/model/posting_model.dart';

class UserModel extends ContactModel {
  String? email;
  String? password;
  bool? isCurrentlyHosting;
  bool? isAdmin;
  DocumentSnapshot? snapshot;
  String? profileImageUrl;
  List<SubscrtiptionModel>? subscriptions;
  List<PostingModel>? savedsubscriptions;

  List<PostingModel>? savedPostings;
  List<PostingModel>? myPostings;

  UserModel({
    String super.id,
    String super.firstName,
    String super.lastName,
    super.displayImage,
    this.email = "",
    this.profileImageUrl,
    this.isAdmin = false,
  }) {
    isCurrentlyHosting = false;

    subscriptions = [];
    savedsubscriptions = [];

    savedPostings = [];
    myPostings = [];
  }

  createContactFromUser() {
    return ContactModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      displayImage: displayImage,
    );
  }

  Future<void> saveUssserToFirestore() async {
    Map<String, dynamic> dataMap = {
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "profileImageUrl": profileImageUrl,
      "myPostingIDs": [],
      "savedPostingIDs": [],
      "earnings": 0,
    };
    await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
  }

  ////////////////////////////////////////////////////////////////
  addPostingToMyPosting(PostingModel posting) async {
    myPostings!.add(posting);

    // Update Firestore using FieldValue.arrayUnion
    await FirebaseFirestore.instance.collection("users").doc(id!).update({
      'myPostingIDs': FieldValue.arrayUnion([posting.id!]),
    });
  }

  removePostingfromMyPosting(PostingModel posting) async {
    for (int i = 0; i < myPostings!.length; i++) {
      if (myPostings![i].id == posting.id) {
        myPostings!.removeAt(i);
        break;
      }
    }
    // ignore: non_constant_identifier_names
    List<String> MyPostingIDs = [];
    // ignore: avoid_function_literals_in_foreach_calls, non_constant_identifier_names
    myPostings!.forEach((Posting) {
      MyPostingIDs.add(Posting.id!);
    });
    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'myPostingIDs': MyPostingIDs,
    });
    Get.snackbar("Posting Removed", "Posting removed successfully");
  }

  Future<void> deletePostFromHostMyPostings(PostingModel posting) async {
    if (posting.host != null && posting.host?.id != null) {
      var hostUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(posting.host?.id)
          .get();
      if (hostUserDoc.exists) {
        try {
          List<String> myPostingIDs = List<String>.from(
            hostUserDoc['myPostingIDs'] ?? [],
          );
          myPostingIDs.remove(posting.id);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(posting.host?.id)
              .update({'myPostingIDs': myPostingIDs});
        } catch (e) {
          // ignore errors
        }
      }
    }
  }

  //////////////////////////////////////////////////////////////////////
  getMypostingFromFirestore() async {
    myPostings!.clear();
    if (snapshot != null && snapshot!.exists) {
      List<String> myPostingIDs = List<String>.from(snapshot!['myPostingIDs']);

      List<Future> futures = [];
      for (String postingID in myPostingIDs) {
        PostingModel posting = PostingModel(id: postingID);
        futures.add(
          Future(() async {
            await posting.getPostingInfoFromFirestore();
            await posting.getAllsubscriptionsFromFirestore();
            myPostings!.add(posting);
          }),
        );
      }
      await Future.wait(futures);
    } else {
      // Handle the case where snapshot is null or does not exist
      return; // Exit the method if there's no valid snapshot
    }
  }

  Future<void> refreshSnapshot() async {
    snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();
  }

  Future<void> fetchSavedPostingsFromFirestore() async {
    savedPostings!.clear();
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .get();
    if (userSnapshot.exists) {
      List<String> savedPostingIDs = List<String>.from(
        userSnapshot['savedPostingIDs'] ?? [],
      );
      savedPostings!
          .clear(); // Clear existing postings before fetching new ones
      for (String postingID in savedPostingIDs) {
        PostingModel posting = PostingModel(id: postingID);
        await posting.getPostingInfoFromFirestore(); // Fetch posting details
        savedPostings!.add(posting); // Add to saved postings list
      }
    }
  }

  addSavedPosting(PostingModel posting) async {
    for (var savedPosting in savedPostings!) {
      if (savedPosting.id == posting.id) {
        return;
      }
    }
    savedPostings!.add(posting);
    List<String> savedPostingIDs = [];
    // ignore: avoid_function_literals_in_foreach_calls
    savedPostings!.forEach((savedPosting) {
      savedPostingIDs.add(savedPosting.id!);
    });
    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'savedPostingIDs': savedPostingIDs,
    });
    Get.snackbar("Marked as Favorite", "Saved to your Favorite List.");
  }

  removeSavedPosting(PostingModel posting) async {
    for (int i = 0; i < savedPostings!.length; i++) {
      if (savedPostings![i].id == posting.id) {
        savedPostings!.removeAt(i);
        break;
      }
    }
    List<String> savedPostingIDs = [];

    savedPostings!.forEach((savedPosting) {
      savedPostingIDs.add(savedPosting.id!);
    });
    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'savedPostingIDs': savedPostingIDs,
    });
    Get.snackbar("posting Removed", "posting removed from your Favorite List.");
  }

  Future<void> addSubscriptionToFirestore(
    SubscrtiptionModel subscription,
    double totalPriceForAllNights,
  ) async {
    Map<String, dynamic> data = {
      'dates': subscription.dates,
      'postingID': subscription.posting!.id!,
      'paid': totalPriceForAllNights,
    };
    await FirebaseFirestore.instance
        // ignore: unnecessary_brace_in_string_interps
        .doc('users/${id}/subscriptions/${subscription.id}')
        .set(data);
    subscriptions!.add(subscription);
  }

  Future<void> getSubscribedPostingsFromFirestore() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .get();
    if (userSnapshot.exists) {
      QuerySnapshot subscriptionsSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .collection('subscriptions')
          .get();
      savedsubscriptions!.clear();
      for (var doc in subscriptionsSnapshot.docs) {
        String postingID = doc['postingID'];
        PostingModel posting = PostingModel(id: postingID);
        await posting.getPostingInfoFromFirestore();
        savedsubscriptions!.add(posting);
      }
    }
  }

  Future<void> removeSubscriptionPostingFromFirestoreUser(
    PostingModel posting,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(AppConstants.currentUser.id)
        .collection('subscriptions')
        .where('postingID', isEqualTo: posting.id)
        .get()
        .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.delete();
          }
        });

    AppConstants.currentUser.savedsubscriptions!.removeWhere(
      (p) => p.id == posting.id,
    );

    Get.snackbar("Removed", "Posting removed from your subscriptions");
  }

  Future<void> removeSubscriptionFromFirestorePost(PostingModel posting) async {
    final subscriptionsRef = FirebaseFirestore.instance
        .collection('postings')
        .doc(posting.id)
        .collection('subscriptions');

    final querySnapshot = await subscriptionsRef
        .where('UserID', isEqualTo: AppConstants.currentUser.id)
        .get();

    await Future.forEach(querySnapshot.docs, (doc) => doc.reference.delete());

    // Remove from local list
    posting.subscriptions?.removeWhere(
      (subscription) => subscription.userId == AppConstants.currentUser.id,
    );
  }

  List<PostingModel> getAllSubscribedPostings() {
    return savedsubscriptions ?? [];
  }

  List<DateTime> getAllSubscribedDates() {
    List<DateTime> allsubscribedDates = [];
    // ignore: avoid_function_literals_in_foreach_calls
    savedsubscriptions!.forEach((posting) {
      // ignore: avoid_function_literals_in_foreach_calls
      posting.subscriptions!.forEach((subscription) {
        allsubscribedDates.addAll(subscription.dates!);
      });
    });
    return allsubscribedDates;
  }
}
