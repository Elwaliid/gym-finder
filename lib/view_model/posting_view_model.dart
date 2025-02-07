import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gym_finder/global.dart';

import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';

class PostingViewModel {
  addListingInfoToFirestore() async {
    //postingModel.setImagesNames();

    Map<String, dynamic> dataMap = {
      "address": postingModel.address,
      "price": postingModel.price,
      "imageNames": /* postingModel.imageNames*/ "asasas",
      "amenities": postingModel.amenities,
      "description": postingModel.description,
      "beds": postingModel.beds,
      "bathrooms": postingModel.bathrooms,
      "type": postingModel.type,
      "rating": 3.5,
      "name": postingModel.name,
      "hostID": AppConstants.currentUser.id,
      "country": postingModel.country,
      "city": postingModel.city,
    };
    DocumentReference ref =
        await FirebaseFirestore.instance.collection("postings").add(dataMap);
    postingModel.id = ref.id;
    await AppConstants.currentUser.addPostingToMyPosting(postingModel);
  }

//llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll
  /* addImagesToFirebaseStorage() async {
    for (int i = 0; i < postingModel.displayImages!.length; i++) {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("postingImages")
          .child(postingModel.id!)
          .child(postingModel.imageNames![i]);
      await ref
          .putData(postingModel.displayImages![i].bytes)
          .whenComplete(() {});
    }
  }*/
}
