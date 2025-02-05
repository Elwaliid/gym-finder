import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: "AIzaSyD7T_aRwQoyG8ebw3to9lY6AxptoeLRBOo",
      authDomain: "gyms-9788e.firebaseapp.com",
      projectId: "gyms-9788e",
      storageBucket: "gyms-9788e.firebasestorage.app",
      messagingSenderId: "827832730732",
      appId: "1:827832730732:web:f84e59fee7ba10fb154449",
      measurementId: "G-JWJCE80WH5",
    ));
  }
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gym Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
