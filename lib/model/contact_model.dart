import 'package:flutter/material.dart';
import 'package:gym_finder/model/user_model.dart';

class ContactModel {
  String? id;
  String? firstName;
  String? lastName;
  String? fullname;
  MemoryImage? displayImage;

  ContactModel(
      {this.id = "",
      this.firstName = "",
      this.lastName = "",
      this.displayImage});

  String getFullNameOfUser() {
    return fullname = "${firstName!}${lastName!}";
  }

  UserModel creatUserFromContact() {
    return UserModel(
      id: id!,
      firstName: firstName!,
      lastName: lastName!,
      displayImage: displayImage!,
    );
  }
}

class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? fullname;
  MemoryImage? displayImage;

  UserModel(
      {this.id = "",
      this.firstName = "",
      this.lastName = "",
      this.displayImage});

  set country(country) {}

  set imagePath(imagePath) {}

  set password(password) {}

  set email(email) {}

  set bio(bio) {}

  set city(city) {}
}
