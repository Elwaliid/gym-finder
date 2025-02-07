import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/booking_model.dart';
import 'package:gym_finder/model/contact_model.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/model/review_model.dart';

class UserModel extends ContactModel {
  String? email;
  String? password;
  String? bio;
  String? city;
  String? country;
  bool? isHost;
  bool? isCurrentlyHosting;
  DocumentSnapshot? snapshot;

  List<BookingModel>? booking;
  List<ReviewModel>? reviews;
  List<PostingModel>? myPostings;

  UserModel({
    String super.id,
    String super.firstName,
    String super.lastName,
    super.displayImage,
    this.email = "",
    this.bio = "",
    this.city = "",
    this.country = "",
  }) {
    isHost = false;
    isCurrentlyHosting = false;
  }
  Future<void> saveUssserToFirestore() async {
    Map<String, dynamic> dataMap = {
      "bio": bio,
      "city": city,
      "country": country,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "isHost": false,
      "myPostingIDs": [],
      "savedPostingIDs": [],
      "earnings": 0,
    };
    await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
  }

  addPostingToMyPosting(PostingModel posting) async {
    myPostings!.add(posting);

    List<String> myPostingIDsList = [];
    myPostings!.forEach((element) {
      myPostingIDsList.add(element.id!);
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({'myPostingIDs': myPostingIDsList});
    await AppConstants.currentUser.addPostingToMyPosting(posting);
  }

  getMypostingFromFirestore() async {
    List<String> myPostingIDs =
        List<String>.from(snapshot!['myPostingIDs']) ?? [];
    for (String postingID in myPostingIDs) {
      PostingModel posting = PostingModel(id: postingID);

      await posting.getPostingInfoFromFirestore();
      // await posting.getAllImagesFromStorage();
      myPostings!.add(posting);
    }
  }
}
