import 'package:chatbuddy/registration/userCredentialsActivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

import '../ScreenBasicElements/ScreenBasicElements.dart';

class OtpAuthentication extends StatefulWidget {
  final String? verificationId;
  const OtpAuthentication({super.key, this.verificationId});
  static const activityName = '/otpAuthentication';

  @override
  State<OtpAuthentication> createState() => _OtpAuthenticationState();
}

class _OtpAuthenticationState extends State<OtpAuthentication>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> offsetAnimation;

  FocusNode otpFN = FocusNode();

  TextEditingController otpController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    offsetAnimation = Tween(begin: const Offset(1, 0), end: Offset.zero)
        .animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    animationController.forward();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initialize(context);
    String otpCode = otpController.text.trim();

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 0, 77, 139)),
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        appBar: AppBar(
          elevation: 30,
          shadowColor: Colors.black,
          backgroundColor: const Color.fromARGB(255, 0, 77, 139),
          title: const Text('ChatBuddy'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Text for Varification
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.2,
                    left: screenWidth * 0.07,
                    right: screenWidth * 0.07),
                child: Text(
                  'Varification',
                  style: TextStyle(
                      fontSize: screenHeight * 0.05,
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
                  'Enter OTP that we have send to your number',
                  style: TextStyle(fontSize: screenHeight * 0.03),
                ),
              ),

              // ! TextField for OTP
              SlideTransition(
                position: offsetAnimation,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.05,
                    left: screenWidth * 0.07,
                    right: screenWidth * 0.07,
                  ),
                  child: PinCodeTextField(
                    pinBoxWidth: screenWidth * 0.1,
                    pinBoxHeight: screenHeight * 0.08,
                    autofocus: true,
                    isCupertino: true,
                    highlight: true,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    pinBoxColor: Colors.blueAccent,
                    errorBorderColor: Colors.red,
                    focusNode: otpFN,
                    controller: otpController,
                    highlightColor: Colors.black,
                    defaultBorderColor: Colors.black,
                    hasTextBorderColor: Colors.grey,
                    pinBoxDecoration:
                        ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                    pinTextStyle: const TextStyle(fontSize: 22.0),
                    onDone: (pin) {
                      if (pin == otpCode) {
                        const Center(child: CircularProgressIndicator());
                      } else {
                        'Invalid OTP';
                      }
                    },
                  ),
                ),
              ),

              //! Continue Button
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
                          try {
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                                    verificationId: widget.verificationId!,
                                    smsCode: otpCode);
                            await auth.signInWithCredential(credential);

                            // ignore: use_build_context_synchronously
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const UserCredentialsActivity()),
                                (route) => false);
                          } catch (e) {
                            const ScaffoldMessenger(
                                child: SnackBar(content: Text('Invalid Otp')));
                            // ignore: avoid_print
                            print(e);
                          }
                        },
                        child: Center(
                          child: Text(
                            'Continue',
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
}
