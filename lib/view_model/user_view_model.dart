import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserViewModel {
  signUp(email, password, firstName, lastName, city, country, bio,
      imagePath) async {
    Get.snackbar("pleas wait", "we are creating an account for you ");

    try {
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
        await saveUserToFirestore(bio, city, country, email, firstName,
                lastName, currentUserId, imagePath)
            .whenComplete(() {
          //  addImageToFirebaseStorage(currentUserId, imagePath);
        });
        Get.snackbar("Congratulations", "your account has been created ");
      });
    } catch (e) {
      Get.snackbar("error", e.toString());
    }
  }

  Future<void> saveUserToFirestore(
      bio, city, country, email, firstName, lastName, id, imagePath) async {
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
      "members": 0,
      "image":
          imagePath, // add me a function in this file that convert imagePath to byts and put it here
    };
    await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
  }
}
