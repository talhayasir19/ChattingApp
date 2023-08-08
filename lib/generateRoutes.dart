import 'package:chatbuddy/registration/numberAuthentication.dart';
import 'package:chatbuddy/registration/otpAuthentication.dart';
import 'package:chatbuddy/registration/userCredentialsActivity.dart';
import 'package:flutter/material.dart';

import 'mainScreens/homeScreen.dart';

Route onGenerateRoute(RouteSettings settings) {
  //! NumberAuthentication
  if (settings.name == NumberAuthentication.activityName) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NumberAuthentication(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        reverseTransitionDuration: const Duration(seconds: 2),
        transitionDuration: const Duration(seconds: 2));
  }

  //! OtpAuthentication
  else if (settings.name == OtpAuthentication.activityName) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OtpAuthentication(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween(begin: const Offset(-1, 0), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionDuration: const Duration(milliseconds: 500));
  }

  //! UserCredentialsActivity
  else if (settings.name == UserCredentialsActivity.activityName) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UserCredentialsActivity(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        reverseTransitionDuration: const Duration(seconds: 1),
        transitionDuration: const Duration(seconds: 1));
  }

  // ! HomeScreen
  else if (settings.name == HomeScreen.activityName) {
    return MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    );
  }

  // ! ChatScreen
  else {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UserCredentialsActivity(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            ),
        transitionDuration: const Duration(seconds: 1),
        reverseTransitionDuration: const Duration(seconds: 1));
  }
}
