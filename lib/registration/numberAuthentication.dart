import 'package:chatbuddy/ScreenBasicElements/ScreenBasicElements.dart';
import 'package:chatbuddy/registration/otpAuthentication.dart';
import 'package:chatbuddy/validatorMixin/validatorMixin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neopop/neopop.dart';

import '../main.dart';

class NumberAuthentication extends StatefulWidget {
  const NumberAuthentication({super.key});
    static const activityName = '/numberAuthentication';

  @override
  State<NumberAuthentication> createState() => _NumberAuthenticationState();
}

class _NumberAuthenticationState extends State<NumberAuthentication>
    with SingleTickerProviderStateMixin, FormValidationMixin {
      
  GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  late AnimationController animationController;
  late Animation<Offset> offsetAnimation;

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    offsetAnimation = Tween(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 0, 77, 139)),
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        appBar: AppBar(
            elevation: 30,
            backgroundColor: const Color.fromARGB(255, 0, 77, 139),
            title: const Text('ChatBuddy')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.2,
                    left: screenWidth * 0.07,
                    right: screenWidth * 0.07),
                child: Text(
                  'Welcome',
                  style: TextStyle(
                      fontSize: screenHeight * 0.06,
                      fontWeight: FontWeight.bold),
                ),
              ),
              // Simple Text
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.03,
                    left: screenWidth * 0.07,
                    right: screenWidth * 0.07),
                child: Text(
                  'Enter number for registeration then we will send you an OTP',
                  style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.bold),
                ),
              ),

              // ! Number TextFormField
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.1,
                    left: screenWidth * 0.07,
                    right: screenWidth * 0.07),
                child: SlideTransition(
                  position: offsetAnimation,
                  child: TextFormField(
                    controller: numberTEC,
                    keyboardType: TextInputType.name,
                    key: formKey,
                    cursorColor: Colors.black,
                    validator: phoneNumberValidation,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      fillColor: Colors.white10,
                      prefixIconColor: Colors.black.withOpacity(0.6),
                      prefixIcon: const Icon(Icons.phone),
                      filled: true,
                      label: Text(
                        'Number',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      labelStyle: TextStyle(height: screenHeight * 0.006),

                      // ! All Borders
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenWidth * 0.004))),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenWidth * 0.004))),
                      errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenWidth * 0.004))),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.6)),
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenWidth * 0.004))),
                    ),
                  ),
                ),
              ),

              // ! OTP Button
              Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.05,
                      left: screenWidth * 0.07,
                      right: screenWidth * 0.07),
                  child: Container(
                    height: screenHeight * 0.1,
                    color: Colors.blueAccent,
                    child: NeoPopTiltedButton(
                        isFloating: true,
                        decoration: NeoPopTiltedButtonDecoration(
                            showShimmer: true,
                            plunkColor: const Color.fromARGB(255, 10, 95, 145),
                            shadowColor: Colors.black.withOpacity(0.3),
                            color: const Color.fromARGB(255, 0, 77, 139)),
                        onTapUp: () {},
                        onTapDown: () async {
                          if (formKey.currentState!.validate()) {
                            // ! Phone Number Authentication
                            await phoneAuthentication();

                            const ScaffoldMessenger(
                                child: SnackBar(content: Text('succesful')));
                          } else {
                            const ScaffoldMessenger(
                                child: SnackBar(content: Text('Unsuccesful')));
                          }
                        },
                        child: Center(
                          child: Text(
                            'Send OTP',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.03),
                          ),
                        )),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> phoneAuthentication() async {
    String phoneNumber = numberTEC.text;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpAuthentication(
                verificationId: verificationId,
              ),
            ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // const Duration(seconds: 14);
      },
    );
  }
}
