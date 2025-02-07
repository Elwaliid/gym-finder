import 'dart:io';
import 'dart:typed_data';
import 'package:gym_finder/main.dart';
import 'package:gym_finder/model/user_model.dart';
import 'package:gym_finder/view/guest_home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/view/guestScreens/account_screen.dart';
import 'package:gym_finder/view/login_sceen.dart';

class UserViewModel {
  UserModel userModel = UserModel();
  Future<void> signUp(
      String email,
      String password,
      String firstName,
      String lastName,
      String city,
      String country,
      String bio,
      File? imageFileOfUser) async {
    try {
      Get.snackbar("Please wait", "We are creating an account for you...");

      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
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
          bio, city, country, email, firstName, lastName, currentUserId);

      /* if (imageFileOfUser != null) {
        await addImageToSupabaseStorage(imageFileOfUser, currentUserId);
      }*/

      Get.offAll(() => const GuestHomeScreen());
      Get.snackbar("Congratulations", "Your account has been created!");
    } catch (e) {
      Get.snackbar("Sign Up Failed", e.toString());
    }
  }

  Future<void> saveUserToFirestore(String bio, String city, String country,
      String email, String firstName, String lastName, String id) async {
    try {
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
    } catch (e) {
      print("Error saving user to Firestore: $e");
    }
  }

/*  Future<void> addImageToSupabaseStorage(
      File imageFileOfUser, String userId) async {
    try {
      final String filePath = 'userImages/$userId.png';
      print("Uploading image to Supabase Storage: $filePath");

      final Uint8List imageBytes = await imageFileOfUser.readAsBytes();

      await supabase.storage.from('images').uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(upsert: true, contentType: 'image/png'),
          );

      String imageUrl = supabase.storage.from('images').getPublicUrl(filePath);
      print("Image uploaded successfully: $imageUrl");
    } catch (e) {
      print("Error uploading image to Supabase: $e");
    }
  }*/

  Future<void> login(String email, String password) async {
    try {
      Get.snackbar("Please wait", "Checking your credentials...");
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String currentUserId = result.user!.uid;
      AppConstants.currentUser.id = currentUserId;

      await getUserinfoFromFirestore(currentUserId);
      // await ImageFromStorage(currentUserId);
      AppConstants.currentUser.getMypostingFromFirestore();
      Get.snackbar("Logged In", "You are logged in successfully!");
      Get.offAll(() => const GuestHomeScreen());
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    }
  }

  Future<void> getUserinfoFromFirestore(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        AppConstants.currentUser.snapshot = snapshot;
        AppConstants.currentUser.firstName = snapshot["firstName"] ?? "";
        AppConstants.currentUser.lastName = snapshot['lastName'] ?? "";
        AppConstants.currentUser.email = snapshot['email'] ?? "";
        AppConstants.currentUser.bio = snapshot['bio'] ?? "";
        AppConstants.currentUser.city = snapshot['city'] ?? "";
        AppConstants.currentUser.country = snapshot['country'] ?? "";
        AppConstants.currentUser.isHost = snapshot['isHost'] ?? false;
      }
    } catch (e) {
      print("Error retrieving user info: $e");
    }
  }

  /*Future<MemoryImage?> getImageFromSupabaseStorage(String userId) async {
    try {
      final String filePath = 'userImages/$userId.png';
      final Uint8List? imageData =
          await supabase.storage.from('images').download(filePath);

      if (imageData != null) {
        AppConstants.currentUser.displayImage = MemoryImage(imageData);
        return AppConstants.currentUser.displayImage;
      }
    } catch (e) {
      print("Error retrieving image from Supabase: $e");
    }
    return null;
  }*/

  becomeHost(String userID) async {
    UserModel userModel = UserModel();
    userModel.isHost = true;
    Map<String, dynamic> dataMap = {
      "isHost": true,
    };
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .update(dataMap);
  }

  modifyCurrentlyHosting(bool isHosting) {
    userModel.isCurrentlyHosting = isHosting;
  }
}
