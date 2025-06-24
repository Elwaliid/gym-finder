// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
// ignore: unnecessary_import
import 'package:get/get_core/src/get_main.dart';
import 'package:gym_finder/global.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';

class PostingViewModel {
  addListingInfoToFirestore() async {
    double mainPriceMonth = 0;
    double mainPrice3Months = 0;
    double mainPrice1Year = 0;
    double mainPrice1Session = 0;
    if (postingModel.type.isNotEmpty) {
      String firstType = postingModel.type.first;
      if (postingModel.pricesPerTypeDuration.containsKey(firstType)) {
        Map<String, double> pricesMap =
            postingModel.pricesPerTypeDuration[firstType]!;
        mainPriceMonth = pricesMap["1Month"] ?? 0;
        mainPrice3Months = pricesMap["3Months"] ?? 0;
        mainPrice1Year = pricesMap["1Year"] ?? 0;
        mainPrice1Session = pricesMap["1Session"] ?? 0;
      }
    }

    Map<String, dynamic> dataMap = {
      "address": postingModel.address,
      "phone": postingModel.phone,
      "email": postingModel.email,
      "pricesPerTypeDuration": postingModel.pricesPerTypeDuration,
      "mainPriceMonth": mainPriceMonth,
      "mainPrice3Months": mainPrice3Months,
      "mainPrice1Year": mainPrice1Year,
      "mainPrice1Session": mainPrice1Session,
      "PostingPhotosUrl": postingModel.imageNames,
      "description": postingModel.description,
      "places": postingModel.places,
      "type": postingModel.type,
      "name": postingModel.name,
      "hostID": AppConstants.currentUser.id,
      "state": postingModel.state,
      "city": postingModel.city,
      "isValid": false,
    };
    DocumentReference ref =
        await FirebaseFirestore.instance.collection("postings").add(dataMap);
    postingModel.id = ref.id;
    await AppConstants.currentUser.addPostingToMyPosting(postingModel);
  }

  updatePostingInfoFirestore(
      {required List<String> pickedBase64Images,
      required List<String> existingBase64Images}) async {
    try {
      List<String> allBase64Images = [
        ...existingBase64Images,
        ...pickedBase64Images
      ];

      double mainPriceMonth = 0;
      double mainPrice3Months = 0;
      double mainPrice1Year = 0;
      double mainPrice1Session = 0;
      if (postingModel.type.isNotEmpty) {
        String firstType = postingModel.type.first;
        if (postingModel.pricesPerTypeDuration.containsKey(firstType)) {
          Map<String, double> pricesMap =
              postingModel.pricesPerTypeDuration[firstType]!;
          mainPriceMonth = pricesMap["1Month"] ?? 0;
          mainPrice3Months = pricesMap["3Months"] ?? 0;
          mainPrice1Year = pricesMap["1Year"] ?? 0;
          mainPrice1Session = pricesMap["1Session"] ?? 0;
        }
      }

      Map<String, dynamic> dataMap = {
        "address": postingModel.address,
        "phone": postingModel.phone,
        "email": postingModel.email,
        "places": postingModel.places,
        "city": postingModel.city,
        "state": postingModel.state,
        "description": postingModel.description,
        "hostID": AppConstants.currentUser.id,
        "PostingPhotosUrl": allBase64Images,
        "name": postingModel.name,
        "pricesPerTypeDuration": postingModel.pricesPerTypeDuration,
        "mainPriceMonth": mainPriceMonth,
        "mainPrice3Months": mainPrice3Months,
        "mainPrice1Year": mainPrice1Year,
        "mainPrice1Session": mainPrice1Session,
        "type": postingModel.type,
      };
      await FirebaseFirestore.instance
          .collection("postings")
          .doc(postingModel.id)
          .update(dataMap);
    } catch (e) {
      print("Error in updatePostingInfoFirestore: $e");
      rethrow;
    }
  }

  removePosting(PostingModel posting) async {
    await FirebaseFirestore.instance
        .collection("postings")
        .doc(posting.id)
        .delete();
    Get.snackbar("Posting Removed", "Posting removed successfully");
  }
}
