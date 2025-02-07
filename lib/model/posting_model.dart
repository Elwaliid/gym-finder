import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gym_finder/model/booking_model.dart';
import 'package:gym_finder/model/contact_model.dart';
import 'package:gym_finder/model/review_model.dart';

class PostingModel {
  String? id;
  String? name;
  String? type;
  double? price;
  String? description;
  String? address;
  String? city;
  String? country;
  double? rating;

  ContactModel? host;
  List<String>? imageNames;
  List<MemoryImage>? displayImages;
  List<String>? amenities;

  Map<String, int>? beds;
  Map<String, int>? bathrooms;

  List<BookingModel>? bookings;
  List<ReviewModel>? reviews;

  PostingModel({
    this.id = "",
    this.name = "",
    this.type = "",
    this.price = 0.0,
    this.description = "",
    this.address = "",
    this.city = "",
    this.country = "",
    this.host,
  }) {
    displayImages = [];
    amenities = [];
    beds = {};
    bathrooms = {};
    rating = 0;

    bookings = [];
    reviews = [];
  }

  setImagesNames() {
    imageNames = [];
    for (int i = 0; i < displayImages!.length; i++) {
      imageNames!.add("image${i}.png");
    }
  }

  getPostingInfoFromFirestore() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('postings').doc(id).get();

    getPostingInfoFromSnapshot(snapshot);
  }

  getPostingInfoFromSnapshot(DocumentSnapshot snapshot) {
    address = snapshot['address'] ?? "";
    city = snapshot['city'] ?? "";
    country = snapshot['country'] ?? "";
    name = snapshot['name'] ?? "";
    type = snapshot['type'] ?? "";
    price = snapshot['price'].toDouble() ?? 0.0;
    description = snapshot['description'] ?? "";
    String hostID = snapshot['hostID'] ?? "";
    host = ContactModel(id: hostID);
    amenities = List<String>.from(snapshot['amenities'] ?? []);
    bathrooms = Map<String, int>.from(snapshot['bathrooms'] ?? {});
    beds = Map<String, int>.from(snapshot['beds'] ?? {});
    // imageNames = List<String>.from(snapshot['imageNames'] ?? []);
    rating = snapshot['rating'].toDouble() ?? 0.0;
  }

  /* getAllImagesFromStorage() async {
    displayImages = [];
    for (int i = 0; i < imageNames!.length; i++) {
      final imageData = await FirebaseStorage.instance
          .ref()
          .child("postingimages")
          .child(id!)
          .child(imageNames![i])
          .getData(1024 * 1024);
      displayImages!.add(MemoryImage(imageData!));
    }
    return displayImages;
  }*/
}
