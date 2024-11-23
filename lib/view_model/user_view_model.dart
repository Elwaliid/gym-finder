import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_storage/firebase_storage.dart';

class UserViewModel {
  signUp(email, password, firstName, lastName, city, country, bio,
      imageFileOfUser) async {
    Get.snackbar("pleas wait", "we are creating an account for you ");
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((result) async {
      String currentUserId = result.user!.uid;

      AppConstants.currentUser.id = currentUserId;
      AppConstants.currentUser.firstName = firstName;
      AppConstants.currentUser.lastName = lastName;
      AppConstants.currentUser.city = city;
      AppConstants.currentUser.country = country;
      AppConstants.currentUser.bio = bio;
      AppConstants.currentUser.email = email;
      AppConstants.currentUser.password = password;
      await saveUserToFirestore(
              bio, city, country, email, firstName, lastName, currentUserId)
          .whenComplete(() {
        addImageToFirebaseStorage(imageFileOfUser, currentUserId);
      });
      Get.snackbar("Congratulations", "your account has been created ");
    });
  }

  Future<void> saveUserToFirestore(
      bio, city, country, email, firstName, lastName, id) async {
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

  addImageToFirebaseStorage(File imageFileOfUser, currentUserId) async {
    Reference referenceStorage = FirebaseStorage.instance
        .ref()
        .child("userImages")
        .child(currentUserId)
        .child(currentUserId + ".png");
    await referenceStorage.putFile(imageFileOfUser).whenComplete(() {});
    AppConstants.currentUser.displayImage =
        MemoryImage(imageFileOfUser.readAsBytesSync());
  }
}
