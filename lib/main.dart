import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_finder/view/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
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
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Initialize Supabase
  /*WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:
        "https://orcqmxepeqfayfxpzbef.supabase.co", // Replace with your Supabase URL
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9yY3FteGVwZXFmYXlmeHB6YmVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgzNDQzMDEsImV4cCI6MjA1MzkyMDMwMX0.AZQlJ0wACFbb9tIMw2LmpVp7ieoaXJg-v-BHA7MawsU", // Replace with your Supabase anon key
  );*/

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gym Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          color: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
