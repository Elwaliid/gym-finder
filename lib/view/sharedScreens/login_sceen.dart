// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/global.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/view/sharedScreens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextEditingController =
      TextEditingController(text: 'walid@gmail.com');
  final _passwordTextEditingController =
      TextEditingController(text: 'walid123');
  @override
  // ignore: must_call_super
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Image.asset(
              "lib/images/login.png",
              width: 400,
              height: 400,
            ),
            const Text(
              "Login to Gym Finder",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
                fontSize: 30.0,
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
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
                              // ignore: deprecated_member_use
                              MaterialStateTextStyle.resolveWith(
                            // ignore: deprecated_member_use
                            (Set<MaterialState> states) {
                              // ignore: deprecated_member_use
                              if (states.contains(MaterialState.focused)) {
                                return const TextStyle(
                                  color: Colors.deepOrange,
                                );
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
                      padding: const EdgeInsets.only(top: 21.0),
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
                        obscureText: true,
                        validator: (valuePasssword) {
                          if (valuePasssword!.length < 5) {
                            return "Password must be at least 6 or more characters";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 26.0, right: 100, left: 100),
                      /*sign in button*/
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await userViewModel.login(
                                _emailTextEditingController.text.trim(),
                                _passwordTextEditingController.text.trim(),
                              );
                              // Prefetch user data after login for faster loading in other screens

                              await AppConstants.currentUser
                                  .getSubscribedPostingsFromFirestore();

                              if (AppConstants.currentUser.isAdmin == false) {
                                await AppConstants.currentUser
                                    .getMypostingFromFirestore();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shadowColor: Colors.deepOrangeAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            "login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Color.fromARGB(255, 175, 180, 180),
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(SignUpScreen());
                      },
                      child: const Text("don't have an account? Create here",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Color.fromARGB(255, 175, 180, 180),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(
                      height: 60,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
