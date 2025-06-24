// ignore_for_file: unused_field, override_on_non_overriding_member, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_finder/global.dart';
import 'package:gym_finder/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatefulWidget {
  UserModel? user;
  SignUpScreen({super.key, this.user});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _firstNameTextEditingController =
      TextEditingController();
  final TextEditingController _lastNameTextEditingController =
      TextEditingController();
  @override
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  XFile? imageFileOfUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 188, 79, 46),
                Color.fromARGB(255, 232, 197, 145),
              ],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          'Create New Accound',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF6E40), // coral red
              Color(0xFFFFF5CC), // pale yellow
              Color(0xFFFFB74D), // warm orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25),
              child: Image.asset(
                "lib/images/signup.png",
                width: 240,
              ),
            ),
            const Text(
              "Tell us about you:",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 188, 79, 46),
                shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 126, 126, 126),
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 26.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "EMAIL",
                          floatingLabelStyle:
                              MaterialStateTextStyle.resolveWith(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.focused)) {
                                return const TextStyle(
                                    color: Colors.deepOrange);
                              }
                              return const TextStyle();
                            },
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                        controller: _emailTextEditingController,
                        validator: (valueEmail) {
                          if (!valueEmail!.contains('@')) {
                            return "please enter a valid email";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "PASSWORD",
                          floatingLabelStyle:
                              MaterialStateTextStyle.resolveWith(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.focused)) {
                                return const TextStyle(
                                    color: Colors.deepOrange);
                              }
                              return const TextStyle();
                            },
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                        controller: _passwordTextEditingController,
                        validator: (valuePasssword) {
                          if (valuePasssword!.length < 5) {
                            return "Password must be at least 6 or more characters";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 21.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "First Name",
                          floatingLabelStyle:
                              MaterialStateTextStyle.resolveWith(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.focused)) {
                                return const TextStyle(
                                    color: Colors.deepOrange);
                              }
                              return const TextStyle();
                            },
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                        controller: _firstNameTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Enter your first name";
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 21.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          floatingLabelStyle:
                              MaterialStateTextStyle.resolveWith(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.focused)) {
                                return const TextStyle(
                                    color: Colors.deepOrange);
                              }
                              return const TextStyle();
                            },
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                        controller: _lastNameTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Enter your last name";
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                var imagefile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (imagefile != null) {
                  setState(() {
                    imageFileOfUser = imagefile;
                  });
                }
              },
              child: Center(
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: imageFileOfUser != null
                      ? NetworkImage(imageFileOfUser!.path)
                      : const AssetImage('lib/images/avatar.png'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 44.0, right: 100, left: 100),
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    Get.snackbar("Field Missing",
                        "Please fill out the complete sign-up form");
                    return;
                  }
                  if (_emailTextEditingController.text.isEmpty ||
                      _passwordTextEditingController.text.isEmpty) {
                    Get.snackbar("Field Missing",
                        "Please fill out the email and password");
                    return;
                  }
                  XFile? myImage;
                  if (imageFileOfUser != null) {
                    myImage = imageFileOfUser;
                  } else {
                    myImage = null;
                  }
                  try {
                    await userViewModel.signUp(
                        _emailTextEditingController.text.trim(),
                        _passwordTextEditingController.text.trim(),
                        _firstNameTextEditingController.text.trim(),
                        _lastNameTextEditingController.text.trim(),
                        myImage);
                  } catch (e) {
                    Get.snackbar("Error", "Sign-up failed: ${e.toString()}");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.deepOrangeAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  "Sign up",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}
