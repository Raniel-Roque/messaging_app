import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/models/message.dart';

class ChatService extends ChangeNotifier {
  //Get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        //Go through each individual user
        final user = doc.data();

        //return user
        return user;
      }).toList();
    });
  }

  //Get all users stream except blocked users

  //Send message
  Future<void> sendMessage(String receiverID, message) async {
    //Get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //Create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //Construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); //Sorts IDs which ensures 2 people have the same chatroomID
    String chatroomID = ids.join('_');

    //Add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //Get message
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    //Construct chatroom ID for 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort(); //Sorts IDs which ensures 2 people have the same chatroomID
    String chatroomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  //Report User
  Future<void> reportUser(String messageID, String userID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageID': messageID,
      'messageOwnerID': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  //Block User
  Future<void> blockUser(String userID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userID)
        .set({});
    notifyListeners();
  }

  //Unblock User
  Future<void> unblockUser(String blockedUserID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserID)
        .delete();
    notifyListeners();
  }

  //Get Blocked Users Stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userID) {
    return _firestore
        .collection('Users')
        .doc(userID)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap(
      (snapshot) async {
        final blockedUserIDs = snapshot.docs.map((doc) => doc.id).toList();

        final userDocs = await Future.wait(
          blockedUserIDs
              .map((id) => _firestore.collection("Users").doc(id).get()),
        );

        return userDocs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      },
    );
  }
}
