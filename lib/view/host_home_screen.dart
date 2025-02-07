import 'package:flutter/material.dart';
import 'package:gym_finder/view/guestScreens/account_screen.dart';
import 'package:gym_finder/view/guestScreens/explore_screen.dart';
import 'package:gym_finder/view/guestScreens/inbox_screen.dart';
import 'package:gym_finder/view/guestScreens/saved_listings_screen.dart';
import 'package:gym_finder/view/guestScreens/trainings_screen.dart';
import 'package:gym_finder/view/hostscreens/bookings_screen.dart';
import 'package:gym_finder/view/hostscreens/my_postings_screen.dart';

class HostHomeScreen extends StatefulWidget {
  const HostHomeScreen({super.key});

  @override
  State<HostHomeScreen> createState() => _HostHomeScreen();
}

class _HostHomeScreen extends State<HostHomeScreen> {
  int selectedIndex = 0;

  final List<String> screenTitles = [
    'Booking',
    'My Postings',
    'Inbox',
    'Profile',
  ];
  final List<Widget> screens = [
    const BookingsScreen(),
    const MyPostingsScreen(),
    const InboxScreen(),
    const AccountScreen(),
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
        color: Colors.deepPurple,
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
            colors: [Colors.pinkAccent, Colors.amber],
            begin: FractionalOffset(0, 0),
            end: FractionalOffset(1, 0),
            stops: [0, 1],
            tileMode: TileMode.clamp,
          )),
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
          items: <BottomNavigationBarItem>[
            customNavigationBarItem(0, Icons.calendar_today, screenTitles[0]),
            customNavigationBarItem(1, Icons.home, screenTitles[1]),
            customNavigationBarItem(2, Icons.message, screenTitles[2]),
            customNavigationBarItem(3, Icons.person_outline, screenTitles[3]),
          ]),
    );
  }
}
