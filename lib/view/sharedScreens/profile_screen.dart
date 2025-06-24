// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/user_model.dart';
import 'package:gym_finder/view/sharedScreens/personal_info_screen.dart';
import 'package:gym_finder/view/sharedScreens/login_sceen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String imageFileOfUser = "";

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    try {
      final userId = AppConstants.currentUser.id;
      if (userId != null && userId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('profileImageData')) {
            String? profileImageUrl = data['profileImageData'];
            if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
              setState(() {
                imageFileOfUser = profileImageUrl;
              });
            }
          }
        }
      }
    } catch (e) {
      // Handle errors if needed, e.g. log or show a message
      print('Error fetching profile image URL: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Confirm Logout',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 188, 79, 46),
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[800],
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 188, 79, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Logout',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Clear current user data by assigning a new empty UserModel
                AppConstants.currentUser = UserModel();
                // Navigate to login screen and clear navigation stack
                Get.offAll(() => const LoginScreen());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 30, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// user info
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                shadowColor: Colors.black54,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
// user name and email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: GestureDetector(
                                onTap: () async {
                                  final XFile? pickedFile = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    try {
                                      final bytes =
                                          await pickedFile.readAsBytes();
                                      final base64String = base64Encode(bytes);
                                      final userId =
                                          AppConstants.currentUser.id;
                                      if (userId != null && userId.isNotEmpty) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .update({
                                          'profileImageData': base64String
                                        });
                                        setState(() {
                                          imageFileOfUser = base64String;
                                        });
                                      }
                                    } catch (e) {
                                      print(
                                          'Error updating profile image: \$e');
                                    }
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: imageFileOfUser.isNotEmpty
                                      ? MemoryImage(
                                          base64Decode(imageFileOfUser))
                                      : const AssetImage(
                                              'lib/images/avatar.png')
                                          as ImageProvider,
                                )),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppConstants.currentUser.getFullNameOfUser(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.currentUser.email.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                shadowColor: Colors.black54,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    children: [
                      //personal info
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Get.to(PersonalInfoScreen());
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 188, 79, 46),
                                Color.fromARGB(255, 232, 197, 145),
                              ],
                              begin: FractionalOffset(0, 0),
                              end: FractionalOffset(1, 0),
                              stops: [0, 1],
                              tileMode: TileMode.clamp,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 24),
                                child: Text(
                                  "Personal Information",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 24),
                                child: Icon(
                                  size: 36,
                                  Icons.person_2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //logout btn
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _showLogoutDialog,
                        child: Container(
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 188, 79, 46),
                                Color.fromARGB(255, 232, 197, 145),
                              ],
                              begin: FractionalOffset(0, 0),
                              end: FractionalOffset(1, 0),
                              stops: [0, 1],
                              tileMode: TileMode.clamp,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 24),
                                child: Text(
                                  "Log out",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 24),
                                child: Icon(
                                  size: 36,
                                  Icons.login_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
