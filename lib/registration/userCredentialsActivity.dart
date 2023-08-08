import 'dart:io';

import 'package:chatbuddy/ScreenBasicElements/ScreenBasicElements.dart';
import 'package:chatbuddy/mainScreens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import '../main.dart';
import '../validatorMixin/validatorMixin.dart';

class UserCredentialsActivity extends StatefulWidget {
  const UserCredentialsActivity({
    super.key,
  });
  static const activityName = '/userCredentialsActivity';

  @override
  State<UserCredentialsActivity> createState() =>
      _UserCredentialsActivityState();
}

class _UserCredentialsActivityState extends State<UserCredentialsActivity>
    with FormValidationMixin, SingleTickerProviderStateMixin {
  // for animation
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

// controllers
  late TextEditingController nameTEC;

// formKey
  GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

// for image picker
  File? pickedImage;
  UploadTask? putFile;
  Reference? ref;

  Future<void> _pickImage(ImageSource source) async {
    final result = await ImagePicker().pickImage(source: source);
    if (result != null) {
      final File imageFile = File(result.path);
      setState(() {
        pickedImage = imageFile;
      });

      final file = File(pickedImage!.path);
      String filePath =
          "profile/${DateTime.now().millisecondsSinceEpoch.toString()}";

      // putFile
      ref = FirebaseStorage.instance.ref().child(filePath);
      putFile = ref!.putFile(file);
    }
  }

// Add User details to firestore
  Future<void> addUserDetails(
      {String? name,
      String? imageUrl,
      String? phoNumber,
      var token}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(numberTEC.text)
        .set({
      'name': name,
      'imageUrl': imageUrl,
      'phoneNumber': phoNumber,
      'token': token
    });
  }

  @override
  void initState() {
    super.initState();
    nameTEC = TextEditingController();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    nameTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initialize(context);
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 0, 77, 139)),
      child: Scaffold(
          backgroundColor: Colors.blueAccent,
          appBar: AppBar(
            title: const Text('ChatBuddy'),
            backgroundColor: const Color.fromARGB(255, 0, 77, 139),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Simple Text
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.1,
                      left: screenWidth * 0.07,
                      right: screenWidth * 0.07),
                  child: Text(
                    'Enter Your full name and select an image to creat account',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.03),
                  ),
                ),

                //! Image
                GestureDetector(
                  onTap: () {
                    if (pickedImage != null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.blueAccent,
                            actions: [
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent),
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).pop();
                                      pickedImage = null;
                                    });
                                  },
                                  child: const Center(
                                      child: Text('Clear Image',
                                          style:
                                              TextStyle(color: Colors.black))),
                                ),
                              )
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.blueAccent,
                          title: const Text(
                            'Pick Image',
                            style: TextStyle(color: Colors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _pickImage(ImageSource.gallery);
                              },
                              child: const Text('From Gallery',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _pickImage(ImageSource.camera);
                              },
                              child: const Text('From Camera',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.05,
                        left: screenWidth * 0.07,
                        right: screenWidth * 0.07),
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 0, 77, 139),
                      radius: screenHeight * 0.1,
                      foregroundImage:
                          pickedImage != null ? FileImage(pickedImage!) : null,
                    ),
                  ),
                ),

                // ! Name TextFormField
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.1,
                      left: screenWidth * 0.07,
                      right: screenWidth * 0.07),
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: TextFormField(
                      controller: nameTEC,
                      keyboardType: TextInputType.name,
                      key: formKey,
                      cursorColor: Colors.black,
                      validator: nameValidation,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        fillColor: Colors.blueAccent,
                        prefixIconColor: Colors.black.withOpacity(0.6),
                        prefixIcon: const Icon(Icons.accessibility),
                        filled: true,
                        label: Text(
                          'Name',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
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
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.6)),
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
                              plunkColor:
                                  const Color.fromARGB(255, 10, 95, 145),
                              shadowColor: Colors.black.withOpacity(0.3),
                              color: const Color.fromARGB(255, 0, 77, 139)),
                          onTapUp: () {},
                          onTapDown: () async {
                            if (formKey.currentState!.validate()) {
                              
                              // token Id
                              var tokenId =
                                  await FirebaseMessaging.instance.getToken();

                              //GetURL
                              putFile!.whenComplete(() {
                                ref!.getDownloadURL().then((value) {
                                  // Add to firestore
                                  addUserDetails(
                                      name: nameTEC.text.trim(),
                                      imageUrl: value,
                                      phoNumber: numberTEC.text,
                                      token: tokenId);

                                  //
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ));
                                });
                              });
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
          )),
    );
  }
}
