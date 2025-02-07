import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:gym_finder/global.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailTextEditingController =
      TextEditingController(text: kDebugMode ? 'walid@gmail.com' : '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: kDebugMode ? 'walid123' : '');
  final TextEditingController _firstNameTextEditingController =
      TextEditingController(text: kDebugMode ? '2Nt7' : '');
  final TextEditingController _lastNameTextEditingController =
      TextEditingController(text: kDebugMode ? '2Nt7W' : '');
  final TextEditingController _cityTextEditingController =
      TextEditingController(text: kDebugMode ? 'example' : '');
  final TextEditingController _countryTextEditingController =
      TextEditingController(text: kDebugMode ? 'example' : '');
  final TextEditingController _bioTextEditingController =
      TextEditingController(text: kDebugMode ? 'asas' : '');

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final SupabaseClient supabase = Supabase.instance.client;

  String imageFileOfUser = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.amber],
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
          colors: [Colors.pinkAccent, Colors.amber],
          begin: FractionalOffset(0, 0),
          end: FractionalOffset(1, 0),
          stops: [0, 1],
          tileMode: TileMode.clamp,
        )),
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
                color: Colors.pink,
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
                        decoration: const InputDecoration(labelText: "EMAIL"),
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
                        decoration:
                            const InputDecoration(labelText: "PASSWORD"),
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
                        decoration:
                            const InputDecoration(labelText: "First Name"),
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
                        decoration:
                            const InputDecoration(labelText: "Last Name"),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 21.0),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "your city"),
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                        controller: _cityTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Enter your city";
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 21.0),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "your country"),
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                        controller: _countryTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Enter your country name";
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 21.0),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: "bio"),
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                        controller: _bioTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Write something in your bio";
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
            if (imageFileOfUser.isNotEmpty)
              Image.network(imageFileOfUser, height: 200, width: 200),
            Padding(
                padding: const EdgeInsets.only(top: 38.0),
                child: MaterialButton(
                    onPressed: () async {
                      var imagefile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (imagefile != null) {
                        setState(() {
                          imageFileOfUser = imagefile.path;
                        });
                        debugPrint("Image picked: imageFileOfUser");
                      }
                    },
                    child: const Icon(Icons.add_a_photo))),
            Padding(
                padding: const EdgeInsets.only(top: 44.0, right: 60, left: 60),
                child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        Get.snackbar("field missing",
                            "please choose image and fill out complet sign up form");
                        return;
                      }
                      if (_emailTextEditingController.text.isEmpty &&
                          _passwordTextEditingController.text.isEmpty) {
                        Get.snackbar("field missing",
                            "pleaseand fill out complet sign up form");
                        return;
                      }
                      ////////////////////////////////////////////////////////////////////
                      ///
                      File myImage = File(imageFileOfUser);

                      Future<void> signUpUser(dynamic Provider) async {
                        if (!_formKey.currentState!.validate()) {
                          Get.snackbar("Field Missing",
                              "Please choose an image and fill out the complete sign-up form");
                          return;
                        }
                        if (_emailTextEditingController.text.isEmpty &&
                            _passwordTextEditingController.text.isEmpty) {
                          Get.snackbar("field missing",
                              "pleaseand fill out complet sign up form");
                          return;
                        }
                        try {
                          // 1️⃣ Sign up the user in Firebase Authentication
                          UserCredential userCredential = await _firebaseAuth
                              .createUserWithEmailAndPassword(
                                  email:
                                      _emailTextEditingController.text.trim(),
                                  password: _passwordTextEditingController.text
                                      .trim());
                          firebase_auth.User? user = userCredential.user;

                          if (user == null) {
                            Get.snackbar("Error",
                                "user creation failed. Please try again.");
                            return;
                          }

                          // 2️⃣ Get Firebase ID Token (JWT)
                          String firebaseJwt =
                              await user.getIdToken(true) ?? '';
                          debugPrint("Firebase JWT: $firebaseJwt");
                          // 3️⃣ Sign in to Supabase using the Firebase JWT
                          final supabaseResponse = await supabase.auth
                              .signInWithIdToken(
                                  provider:
                                      Provider.custom, // Use "custom" provider
                                  idToken: firebaseJwt);

                          if (supabaseResponse.session == null) {
                            Get.snackbar(
                                "Error", "Supabase authentication failed.");
                            return;
                          }
                          // 4️⃣ Upload profile image to Supabase Storage
                          final String fileName =
                              "${user.uid}/${path.basename(imageFileOfUser)}";
                          await supabase.storage.from('images').upload(
                                fileName,
                                myImage,
                                fileOptions: const FileOptions(upsert: true),
                              );

                          // ✅ User successfully signed up
                          Get.snackbar(
                              "Success", "Account created successfully!");
                        } catch (error) {
                          print(
                              "Error during sign-up and image upload: $error");

                          Get.snackbar(
                              "Error", "Sign-up failed: ${error.toString()}");
                        }
                      }

                      userViewModel.signUp(
                          _emailTextEditingController.text.trim(),
                          _passwordTextEditingController.text.trim(),
                          _firstNameTextEditingController.text.trim(),
                          _lastNameTextEditingController.text.trim(),
                          _cityTextEditingController.text.trim(),
                          _countryTextEditingController.text.trim(),
                          _bioTextEditingController.text.trim(),
                          myImage); //
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                    ),
                    child: const Text("Sign up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                            color: Colors.white)))),
            const SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}
