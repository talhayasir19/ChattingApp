// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ScreenBasicElements/ScreenBasicElements.dart';
import '../notifications/notifications.dart';
import '../validatorMixin/validatorMixin.dart';

class ChatScreen extends StatefulWidget {
  final String? name;
  final String? phoneNumber;
  final String? token;

  const ChatScreen({
    Key? key,
    this.name,
    required this.token,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with FormValidationMixin {
// Controller
  late TextEditingController msgTEC;

  FirebaseAuth auth = FirebaseAuth.instance;
  GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  LocalNotificationService localNotificationService =
      LocalNotificationService();

// Add User messages to firestore
  Future<void> addUserMessages({
    String? messages,
    String? phNumber,
    String? currentDate,
    String? currentTime,
    String? timeStamp,
  }) async {
    String x = auth.currentUser!.phoneNumber!;
    int senderPhoneNumber = int.parse(x.substring(3, 12));
    int receiverPhoneNumber = int.parse(widget.phoneNumber!.substring(3, 12));
    int docId = senderPhoneNumber + receiverPhoneNumber;
    await FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(docId.toString())
        .collection('Messages')
        .doc()
        .set({
      'messages': messages,
      'phoneNumber': phNumber,
      'currentDate': currentDate,
      'currentTime': currentTime,
      'timeStamp': timeStamp,
    });
  }

  // Fetch Data from Firestore
  Stream<QuerySnapshot> getMessagesStream() {
    String x = auth.currentUser!.phoneNumber!;
    int senderPhoneNumber = int.parse(x.substring(3, 12));
    int receiverPhoneNumber = int.parse(widget.phoneNumber!.substring(3, 12));
    int docId = senderPhoneNumber + receiverPhoneNumber;
    return FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(docId.toString())
        .collection('Messages')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  // Delete Data from Firestore
  // Future<void> deleteMessage() {
  //   String x = auth.currentUser!.phoneNumber!;
  //   int senderPhoneNumber = int.parse(x.substring(3, 12));
  //   int receiverPhoneNumber = int.parse(widget.phoneNumber!.substring(3, 12));
  //   int docId = senderPhoneNumber + receiverPhoneNumber;
  //   return FirebaseFirestore.instance
  //       .collection('ChatRooms')
  //       .doc(docId.toString())
  //       .collection('Messages')
  //       .doc()
  //       .delete();
  // }

  @override
  void initState() {
    super.initState();
    msgTEC = TextEditingController();
  }

  @override
  void dispose() {
    msgTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  to get current Date
    DateTime dateAndTime = DateTime.now();
    String dateNow =
        "${dateAndTime.day}-${dateAndTime.month}-${dateAndTime.year}";
    String timeNow =
        '${dateAndTime.hour % 12 == 0 ? 12 : dateAndTime.hour % 12}:${dateAndTime.minute.toString().padLeft(2, '0')} ${dateAndTime.hour < 12 ? 'AM' : 'PM'}';

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 0, 77, 139)),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 77, 139),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 77, 139),
          title: Text(widget.name!),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Container(
                  height: screenHeight * 0.8,
                  width: screenWidth,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.1),
                          topRight: Radius.circular(screenWidth * 0.1))),
                  child: StreamBuilder(
                    stream: getMessagesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error${snapshot.error}');
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data!.docs;

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: data.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final message =
                              data[index].data() as Map<String, dynamic>;

                          final isSender = message['phoneNumber'] ==
                              FirebaseAuth.instance.currentUser!.phoneNumber;

                          final alignment = isSender
                              ? Alignment.centerLeft
                              : Alignment.centerRight;

                          return Padding(
                            padding: EdgeInsets.only(
                                right: isSender ? 0.03 : screenWidth * 0.05,
                                left: isSender ? screenWidth * 0.05 : 0.03,
                                bottom: screenHeight * 0.04,
                                top: screenHeight * 0.06),
                            child: Column(
                              crossAxisAlignment: isSender
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                // Message
                                Align(
                                  alignment: alignment,
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(screenWidth * 0.023),
                                    decoration: BoxDecoration(
                                      borderRadius: isSender
                                          ? BorderRadius.only(
                                              topRight: Radius.circular(
                                                  screenWidth * 0.02),
                                              bottomRight: Radius.circular(
                                                  screenWidth * 0.02),
                                              bottomLeft: Radius.circular(
                                                  screenWidth * 0.05))
                                          : BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  screenWidth * 0.02),
                                              bottomLeft: Radius.circular(
                                                  screenWidth * 0.02),
                                              bottomRight: Radius.circular(
                                                  screenWidth * 0.05)),
                                      color: isSender
                                          ? Colors.blue
                                          : Colors.blueAccent,
                                      boxShadow: const [
                                        BoxShadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 0.6,
                                            spreadRadius: 0.7,
                                            color: Color.fromARGB(
                                                255, 14, 31, 59)),
                                        BoxShadow(
                                            offset: Offset(-1, -1),
                                            blurRadius: 0.6,
                                            spreadRadius: 0.7,
                                            color: Color.fromARGB(
                                                255, 117, 162, 240)),
                                      ],
                                    ),
                                    child: Text(message['messages'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.05,
                                        )),
                                  ),
                                ),

                                // currentTime
                                Align(
                                  alignment: alignment,
                                  child: Text(message['currentTime'],
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: screenWidth * 0.033)),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              //
              Container(
                width: screenWidth,
                height: screenHeight * 0.2,
                color: Colors.blueAccent,
                child: Stack(
                  children: [
                    // send messages TextFormField
                    Padding(
                      padding: EdgeInsets.only(
                          right: screenWidth * 0.18,
                          left: screenWidth * 0.02,
                          top: screenHeight * 0.04),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        enableSuggestions: true,
                        key: formKey,
                        controller: msgTEC,
                        cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                        validator: emptyValidation,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          fillColor: Colors.white10,
                          filled: true,
                          hintText: 'Type your messages',
                          // ! All Borders
                          focusedBorder: OutlineInputBorder(
                              gapPadding: screenWidth * 0.01,
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.04)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.04)),
                          errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.04)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(71, 0, 0, 0)),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.04)),
                        ),
                      ),
                    ),

                    // send messages Button
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.83, top: screenHeight * 0.05),
                      child: IconButton(
                          style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Color.fromARGB(255, 0, 77, 139))),
                          iconSize: screenHeight * 0.05,
                          onPressed: () {
                            if (formKey.currentState!.isValid) {
                              addUserMessages(
                                messages: msgTEC.text,
                                phNumber: widget.phoneNumber,
                                currentDate: dateNow,
                                currentTime: timeNow,
                                timeStamp: dateAndTime.toString(),
                              );

                              triggerNotifiation(
                                  tittle: widget.name!,
                                  body: msgTEC.text,
                                  tokenId: widget.token);
                              msgTEC.clear();
                               }
                          },
                          icon: const Icon(color: Colors.white, Icons.send)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
