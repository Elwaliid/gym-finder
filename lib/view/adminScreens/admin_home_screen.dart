import 'package:flutter/material.dart';
import 'package:gym_finder/view/sharedScreens/explore_screen.dart';
import 'package:gym_finder/view/adminScreens/on_hold_screen.dart';
import 'package:gym_finder/view/sharedScreens/profile_screen.dart';
import 'package:gym_finder/view/sharedScreens/subscriptions_screen.dart';
import 'package:gym_finder/view/sharedScreens/saved_gyms_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int selectedIndex = 0;

  final List<String> screenTitles = [
    'Valid',
    'Saved',
    'On Hold',
    'Subscriptions',
    'Profile',
  ];
  final List<Widget> screens = [
    const ExploreScreen(),
    const SavedGymsScreen(),
    const OnHoldScreen(),
    SubscriptionsScreen(),
    const ProfileScreen(),
  ];

  BottomNavigationBarItem customNavigationBarItem(
      int index, IconData iconData, String title) {
    return BottomNavigationBarItem(
      icon: Icon(
        iconData,
        color: Colors.black,
      ),
      activeIcon: Icon(
        iconData,
        color: const Color.fromARGB(255, 188, 79, 46),
      ),
      label: title,
    );
  }

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
        title: Text(
          screenTitles[selectedIndex],
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          setState(() {
            selectedIndex = i;
          });
        },
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 179, 115, 95),
        items: <BottomNavigationBarItem>[
          customNavigationBarItem(0, Icons.verified, screenTitles[0]),
          customNavigationBarItem(1, Icons.favorite_border, screenTitles[1]),
          customNavigationBarItem(
              2, Icons.pause_circle_outline, screenTitles[2]),
          customNavigationBarItem(3, Icons.fitness_center, screenTitles[3]),
          customNavigationBarItem(4, Icons.person_outline, screenTitles[4]),
        ],
      ),
    );
  }
}
