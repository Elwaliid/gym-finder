import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/global.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/view/guest_home_screen.dart';
import 'package:gym_finder/view/host_home_screen.dart';
import 'package:gym_finder/view/signup_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _hostingTitle = "show my Host Dashboard";

  modifyHostingMode() async {
    if (AppConstants.currentUser.isHost!) {
      if (AppConstants.currentUser.isCurrentlyHosting!) {
        AppConstants.currentUser.isCurrentlyHosting = false;

        Get.to(const GuestHomeScreen());
      } else {
        AppConstants.currentUser.isCurrentlyHosting = true;

        Get.to(const HostHomeScreen());
      }
    } else {
      await userViewModel.becomeHost(FirebaseAuth.instance.currentUser!.uid);

      AppConstants.currentUser.isCurrentlyHosting = true;

      Get.to(const HostHomeScreen());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (AppConstants.currentUser.isHost!) {
      if (AppConstants.currentUser.isCurrentlyHosting!) {
        _hostingTitle = "show my Guest Dashboard";
      } else {
        _hostingTitle = "show my Host Dashboard";
      }
    } else {
      _hostingTitle = "Become a Host";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 50, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// user info
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Center(
                child: Column(
                  children: [
                    // image of user
                    /*  if (imageFileOfUser.isNotEmpty)
                      Image.file(imageFileOfUser, height: 200, width: 200),*/

                    const SizedBox(
                      height: 10,
                    ),

// user name and email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.currentUser.getFullNameOfUser(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppConstants.currentUser.email.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: [
                //personal info
                Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.amber],
                    begin: FractionalOffset(0, 0),
                    end: FractionalOffset(1, 0),
                    stops: [0, 1],
                    tileMode: TileMode.clamp,
                  )),
                  child: MaterialButton(
                    height: MediaQuery.of(context).size.height / 9.1,
                    onPressed: () {},
                    child: const ListTile(
                      contentPadding: EdgeInsets.all(0.0),
                      leading: Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        size: 34,
                        Icons.person_2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                //Change Hosting btn
                Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.amber],
                    begin: FractionalOffset(0, 0),
                    end: FractionalOffset(1, 0),
                    stops: [0, 1],
                    tileMode: TileMode.clamp,
                  )),
                  child: MaterialButton(
                    height: MediaQuery.of(context).size.height / 9.1,
                    onPressed: () {
                      modifyHostingMode();
                      setState(() {});
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(0.0),
                      leading: Text(
                        _hostingTitle,
                        style: const TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: const Icon(
                        size: 34,
                        Icons.sports_gymnastics_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                //logout btn
                Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.amber],
                    begin: FractionalOffset(0, 0),
                    end: FractionalOffset(1, 0),
                    stops: [0, 1],
                    tileMode: TileMode.clamp,
                  )),
                  child: MaterialButton(
                    height: MediaQuery.of(context).size.height / 9.1,
                    onPressed: () {},
                    child: const ListTile(
                      contentPadding: EdgeInsets.all(0.0),
                      leading: Text(
                        "Log out",
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        size: 34,
                        Icons.login_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
