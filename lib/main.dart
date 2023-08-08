import 'package:chatbuddy/ScreenBasicElements/ScreenBasicElements.dart';
import 'package:chatbuddy/registration/numberAuthentication.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mainScreens/homeScreen.dart';
import 'notifications/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: const FirebaseOptions(
      //     apiKey: "AIzaSyDNOsEIfEA7M5wDJuevwwzwRhwMTuZsPNY",
      //     authDomain: "chatbuddy-64b3f.firebaseapp.com",
      //     projectId: "chatbuddy-64b3f",
      //     storageBucket: "chatbuddy-64b3f.appspot.com",
      //     messagingSenderId: "790218681172",
      //     appId: "1:790218681172:web:57ed4c63e318d60697b6c1")
      );

  LocalNotificationService localNotificationService =
      LocalNotificationService();

  FirebaseMessaging.onMessage.listen((message) async {
    await localNotificationService.initializeSettingsOfNotifications();
    localNotificationService.initializeSettingsOfNotifications();
    print("Hello");
    localNotificationService.showNotification(
        title: message.notification!.title!, body: message.notification!.body!);
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

TextEditingController numberTEC = TextEditingController();

class _MyAppState extends State<MyApp> {
// Storing user information securely
  Future<void> storeUserInformation(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // Check if the user is already authenticated
  bool checkUserLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      numberTEC.text =
          FirebaseAuth.instance.currentUser!.phoneNumber.toString();
      return true; // User is already authenticated, navigate to the home screen
    } else {
      // User not authenticated, show the login screen
      return false;
    }
  }

  // Once the user is authenticated successfully, store the user information and navigate to the home screen
  void onAuthenticationSuccess(UserCredential userCredential) {
    final user = userCredential.user;
    if (user != null) {
      storeUserInformation(user.uid); // Store user information securely
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    initialize(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: checkUserLoggedIn()
          ? const HomeScreen()
          : const NumberAuthentication(),
    );
  }
}
