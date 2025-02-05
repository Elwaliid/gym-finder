import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

Future<void> saveUserToFirestore(
  String bio,
  String city,
  String country,
  String email,
  String firstName,
  String lastName,
  String id,
  String imagePath,
) async {
  try {
    String? imageUrl = await addImageToFirebaseStorage(id, imagePath);

    if (imageUrl == null) throw Exception("Image upload failed!");

    await FirebaseFirestore.instance.collection("users").doc(id).set({
      "bio": bio,
      "city": city,
      "country": country,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "image": imageUrl,
    });
    Get.snackbar("Success", "Account created successfully!");
  } catch (e) {
    Get.snackbar("Error", "Failed to save user: $e");
  }
}

Future<String?> addImageToFirebaseStorage(
    String userId, String imagePath) async {
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child("userImages/$userId/${userId}_profile.png");
    final file = File(imagePath);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  } catch (e) {
    return null;
  }
}
