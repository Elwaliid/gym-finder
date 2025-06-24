import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gym_finder/global.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/subcripition_model.dart';
import 'package:gym_finder/model/contact_model.dart';

class PostingModel {
  String? id;
  String? name;
  List<String> type;
  // Removed single price field as prices are now per type and duration
  // double? price;
  String? description;
  String? address;
  String? city;
  String? state;
  String? email;
  String? phone;

  ContactModel? host;
  List<String> imageNames;
  List<MemoryImage> displayImages;

  int places;

  bool isValid = false;

  List<SubscrtiptionModel>? subscriptions;
  List<String>? subscribedDates;

  // New field: prices per type and duration
  Map<String, Map<String, double>> pricesPerTypeDuration = {};

  PostingModel({
    // Add hostID to the constructor
    this.id = "",
    this.name = "",
    this.type = const [],
    this.imageNames = const [],
    this.displayImages = const [],

    // this.price = 0.0,
    this.description = "",
    this.address = "",
    this.city = "",
    this.state = "",
    this.email = "",
    this.phone = "",
    this.places = 0,
    // Initialize hostID
    Map<String, Map<String, double>>? pricesPerTypeDuration,
  }) {
    displayImages = [];

    subscriptions = [];
    this.pricesPerTypeDuration = pricesPerTypeDuration ?? {};
  }

  getPostingInfoFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('postings')
        .doc(id)
        .get();

    getPostingInfoFromSnapshot(snapshot);
  }

  Future<void> getPostingInfoFromSnapshot(DocumentSnapshot snapshot) async {
    address = snapshot['address'] ?? "";
    city = snapshot['city'] ?? "";
    email = snapshot['email'] ?? "";
    phone = snapshot['phone'] ?? "";
    state = snapshot['state'] ?? "";
    name = snapshot['name'] ?? "";
    // Try to parse type as List<String> or fallback to empty list
    if (snapshot['type'] is List) {
      type = List<String>.from(snapshot['type']);
    } else if (snapshot['type'] is String) {
      type = (snapshot['type'] as String)
          .split(',')
          .map((e) => e.trim())
          .toList();
    } else {
      type = [];
    }
    // price = snapshot['price'].toDouble() ?? 0.0; // Removed single price
    description = snapshot['description'] ?? "";
    String hostID = snapshot['hostID'] ?? "";
    host = ContactModel(id: hostID);
    await host?.getContactInfoFromFirestore();

    places = snapshot['places'] ?? 0;
    imageNames = List<String>.from(snapshot['PostingPhotosUrl'] ?? []);

    isValid = snapshot['isValid'];

    // Load pricesPerTypeDuration map
    pricesPerTypeDuration = {};
    if (snapshot['pricesPerTypeDuration'] != null) {
      Map<String, dynamic> outerMap = Map<String, dynamic>.from(
        snapshot['pricesPerTypeDuration'],
      );
      outerMap.forEach((typeKey, innerMapDynamic) {
        Map<String, double> innerMap = {};
        Map<String, dynamic> innerMapRaw = Map<String, dynamic>.from(
          innerMapDynamic,
        );
        innerMapRaw.forEach((durationKey, priceValue) {
          innerMap[durationKey] = (priceValue is int)
              ? priceValue.toDouble()
              : (priceValue as double);
        });
        pricesPerTypeDuration[typeKey] = innerMap;
      });
    }
  }

  getAllImagesFromStorage() async {
    displayImages = [];
    for (int i = 0; i < imageNames.length; i++) {
      final imageData = await FirebaseStorage.instance
          .ref()
          .child("postingimages")
          .child(id!)
          .child(imageNames[i])
          .getData(1024 * 1024);
      displayImages.add(MemoryImage(imageData!));
    }
    return displayImages;
  }

  getFirstImageFromStorage() async {
    if (displayImages.isNotEmpty) {
      return displayImages.first;
    }
    final imageData = await FirebaseStorage.instance
        .ref()
        .child("postingImages")
        .child(id!)
        .child(imageNames.first)
        .getData(1024 * 1024);

    displayImages.add(MemoryImage(imageData!));
    return displayImages.first;
  }

  getHostFromFirstore() async {
    try {
      await host!.getContactInfoFromFirestore();
    } catch (e) {
      // ignore: avoid_print
      print("Error in getHostFromFirstore: $e");
      host = null;
    }
    // await host!.getImageFromStorage();
  }

  int getPlacesAvailable() {
    return places;
  }

  String getFullAddress() {
    // ignore: prefer_interpolation_to_compose_strings
    return address! + " , " + city! + "," + state!;
  }

  getAllsubscriptionsFromFirestore() async {
    subscriptions = [];
    QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('subscriptions')
        .get();
    for (var snapshot in snapshots.docs) {
      SubscrtiptionModel newSubscription = SubscrtiptionModel();
      await newSubscription.getSubscriptionInfoFromFirestoresFromPosting(
        this,
        snapshot,
      );

      subscriptions!.add(newSubscription);
    }
  }

  getSubscriptionsFromPostingSubcollection() async {
    subscriptions = [];
    QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('postings')
        .doc(id)
        .collection('subscriptions')
        .get();
    for (var snapshot in snapshots.docs) {
      SubscrtiptionModel newSubscription = SubscrtiptionModel();
      await newSubscription.getSubscriptionInfoFromFirestoreFromPosting(
        this,
        snapshot,
      );

      subscriptions!.add(newSubscription);
    }
  }

  Future<void> makenewSubscription(
    List<DateTime> dates,
    context,
    hostID,
  ) async {
    Map<String, dynamic> subscriptionData = {
      'dates': dates,
      'name': AppConstants.currentUser.getFullNameOfUser(),
      'UserID': AppConstants.currentUser.id,
      'ammount': subPrice,
    };
    DocumentReference reference = await FirebaseFirestore.instance
        .collection('postings')
        .doc(id)
        .collection('subscriptions')
        .add(subscriptionData);
    SubscrtiptionModel newSubscription = SubscrtiptionModel();
    newSubscription.createSubscription(
      this,
      AppConstants.currentUser.creatUserFromContact(),
      dates,
    );
    newSubscription.id = reference.id;
    subscriptions!.add(newSubscription);
    await AppConstants.currentUser.addSubscriptionToFirestore(
      newSubscription,
      subPrice!,
    );
  }

  Future<void> makenewSubscriptionWithPrice(
    List<DateTime> dates,
    context,
    hostID,
    double totalPrice,
  ) async {
    Map<String, dynamic> subscriptionData = {
      'dates': dates,
      'name': AppConstants.currentUser.getFullNameOfUser(),
      'UserID': AppConstants.currentUser.id,
      'ammount': totalPrice,
    };
    DocumentReference reference = await FirebaseFirestore.instance
        .collection('postings')
        .doc(id)
        .collection('subscriptions')
        .add(subscriptionData);
    SubscrtiptionModel newSubscription = SubscrtiptionModel();
    newSubscription.createSubscription(
      this,
      AppConstants.currentUser.creatUserFromContact(),
      dates,
    );
    newSubscription.id = reference.id;
    subscriptions!.add(newSubscription);
    await AppConstants.currentUser.addSubscriptionToFirestore(
      newSubscription,
      totalPrice,
    );
  }
}
