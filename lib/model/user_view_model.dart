import 'dart:convert';
import 'package:gym_finder/model/user_model.dart';
import 'package:gym_finder/view/userScreens/user_home_screen.dart';
import 'package:gym_finder/view/adminScreens/admin_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:image_picker/image_picker.dart';

class UserViewModel {
  UserModel userModel = UserModel();

  Future<void> signUp(String email, String password, String firstName,
      String lastName, XFile? imageFileOfUser) async {
    try {
      Get.snackbar("Please wait", "We are creating an account for you...");
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String currentUserId = result.user!.uid;
      AppConstants.currentUser.id = currentUserId;
      AppConstants.currentUser.firstName = firstName;
      AppConstants.currentUser.lastName = lastName;
      AppConstants.currentUser.email = email;
      AppConstants.currentUser.password = password;
      String? profileImageData;
      if (imageFileOfUser != null) {
        final bytes = await imageFileOfUser.readAsBytes();
        profileImageData = base64Encode(bytes);
        AppConstants.currentUser.profileImageUrl = profileImageData;
      } else {
        profileImageData = null;
      }
      await saveUserToFirestore(
          email, firstName, lastName, currentUserId, profileImageData);
      Get.offAll(() => const UserScreen());
      Get.snackbar("Congratulations", "Your account has been created!");
    } catch (e) {
      Get.snackbar("Sign Up Failed", e.toString());
    }
  }

  Future<void> saveUserToFirestore(String email, String firstName,
      String lastName, String id, String? profileImageData) async {
    try {
      Map<String, dynamic> dataMap = {
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "profileImageData": profileImageData,
        "myPostingIDs": [],
        "savedPostingIDs": [],
        "isAdmin": false,
      };
      await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
    } catch (e) {
      // ignore: avoid_print
      print("Error saving user to Firestore: $e");
    }
  }

  Future<void> updateUserInfo(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      String? userId = AppConstants.currentUser
          .id; // Assuming you have the user ID stored in AppConstants
      Map<String, dynamic> dataMap = {
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
      };

      if (password.isNotEmpty) {
        // Update password logic if needed
        User? user = FirebaseAuth.instance.currentUser;
        await user?.updatePassword(password);
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update(dataMap);
      if (AppConstants.currentUser.isAdmin == true) {
        Get.offAll(() => const AdminScreen());
      } else {
        Get.offAll(() => const UserScreen());
      }
      Get.snackbar("Success", "Personal information updated successfully!");
    } catch (e) {
      Get.snackbar("Update Failed", e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      Get.snackbar("Please wait", "Checking your credentials...");
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String currentUserId = result.user!.uid;
      AppConstants.currentUser.id = currentUserId;

      await getUserinfoFromFirestore(currentUserId);
      Get.snackbar("Logged In", "You are logged in successfully!");
      if (AppConstants.currentUser.isAdmin == true) {
        Get.offAll(() => const AdminScreen());
      } else {
        Get.offAll(() => const UserScreen());
      }
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
        AppConstants.currentUser.isAdmin = snapshot['isAdmin'] ?? false;
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error retrieving user info: $e");
    }
  }

  getImageFromStorage(userID) async {
    if (AppConstants.currentUser.displayImage != null) {
      return AppConstants.currentUser.displayImage;
    }
    // Since no Firebase Storage, return null or default image
    return null;
  }
}
