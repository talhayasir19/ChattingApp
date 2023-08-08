import 'package:chatbuddy/ScreenBasicElements/ScreenBasicElements.dart';
import 'package:chatbuddy/mainScreens/chatScreen.dart';
import 'package:chatbuddy/modelClasses/modelClassForProfileData.dart';
import 'package:chatbuddy/registration/numberAuthentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const activityName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    initialize(context);

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 0, 77, 139)),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 77, 139),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 77, 139),
          title: const Center(child: Text('ChatBuddy')),
        ),
        body: const AllChats(),
        drawer: const Drawer(
          backgroundColor: Color.fromARGB(255, 0, 140, 255),
          child: DrawerHome(),
        ),
      ),
    );
  }
}

class DrawerHome extends StatelessWidget {
  const DrawerHome({super.key});
  fetchData() async {
    return await firebaseFirestore
        .collection('users')
        .doc(numberTEC.text)
        .get();
  }

// For SignOut
  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              ));
            }

            var docdata = snapshot.data! as DocumentSnapshot;

            return Column(
              children: [
                // for Image
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.06, right: screenWidth * 0.3),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: screenHeight * 0.07,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.5),
                          topRight: Radius.circular(screenWidth * 0.5),
                          bottomRight: Radius.circular(screenWidth * 0.5),
                          bottomLeft: Radius.circular(screenWidth * 0.5)),
                      child: Image.network(
                        docdata['imageUrl'],
                        height: screenWidth * 0.5,
                        width: screenWidth * 0.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Text for profile
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.06, right: screenWidth * 0.1),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                        fontSize: screenHeight * 0.032,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // Text for Phone Number
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.03)),
                    tileColor: Colors.blue,
                    leading: const Icon(Icons.phone, color: Colors.black),
                    title: Text(
                      '${docdata['phoneNumber']}',
                      style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ),

                // Text for Name
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.03)),
                    tileColor: Colors.blue,
                    leading: const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    title: Text(
                      '${docdata['name']}',
                      style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ),

                // Button for SignOut
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.03)),
                    tileColor: Colors.blue,
                    leading: const Icon(Icons.undo),
                    iconColor: Colors.black,
                    title: Text(
                      'SignOut',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.026,
                      ),
                    ),
                    onTap: () {
                      signOut();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NumberAuthentication(),
                          ));
                    },
                  ),
                )
              ],
            );
          },
        ),
      ],
    );
  }
}

class AllChats extends StatelessWidget {
  const AllChats({super.key});

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber',
            isNotEqualTo:
                FirebaseAuth.instance.currentUser!.phoneNumber.toString())
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error :${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.blueAccent,
          ));
        }
        return Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.02),
          child: Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.1),
                    topRight: Radius.circular(screenWidth * 0.1))),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                ModelClassForProfileData modelClassForProfileData =
                    ModelClassForProfileData.fromMap(data);
                return Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: screenHeight * 0.04,
                        child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(screenWidth * 0.2),
                                topRight: Radius.circular(screenWidth * 0.2),
                                bottomRight: Radius.circular(screenWidth * 0.2),
                                bottomLeft: Radius.circular(screenWidth * 0.2)),
                            child: Image.network(
                                height: screenWidth * 0.7,
                                width: screenWidth * 0.7,
                                fit: BoxFit.cover,
                                modelClassForProfileData.imageUrl!))),

                    titleTextStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                    title: Text(modelClassForProfileData.name!,
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold)),

                    //
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  ChatScreen(
                                      token: modelClassForProfileData.token,
                                      name: modelClassForProfileData.name,
                                      phoneNumber:
                                          modelClassForProfileData.phNumber),
                              transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              transitionDuration: const Duration(seconds: 1),
                              reverseTransitionDuration:
                                  const Duration(seconds: 1)));
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
