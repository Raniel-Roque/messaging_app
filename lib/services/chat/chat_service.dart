import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Whispr/models/message.dart';

class ChatService extends ChangeNotifier {
  //Get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Get all users stream except blocked users
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      //Get blocked user IDs
      final blockedUserIDs = snapshot.docs.map((doc) => doc.id).toList();

      //Get all users
      final usersSnapshot = await _firestore.collection('Users').get();

      //Return as stream list

      return usersSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != currentUser.email &&
              !blockedUserIDs.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  //Send message
  Future<void> sendMessage(String receiverID, message) async {
    //Get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //Construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); //Sorts IDs which ensures 2 people have the same chatroomID
    String chatroomID = ids.join('_');

    //Create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //Add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //Get message
  Stream<QuerySnapshot> getMessages(String senderID, receiverID) {
    //Construct chatroom ID for 2 users
    List<String> ids = [senderID, receiverID];
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
  Future<void> reportMessage(String messageID, String senderID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageID': messageID,
      'messageOwnerID': senderID,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  //Block User
  Future<void> blockUser(String senderID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(senderID)
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
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String senderID) {
    return _firestore
        .collection('Users')
        .doc(senderID)
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

  //Delete Message
  Future<void> deleteMessage(String messageID, senderID, receiverID) async {
    //Construct chatroom ID for 2 users
    List<String> ids = [senderID, receiverID];
    ids.sort(); //Sorts IDs which ensures 2 people have the same chatroomID
    String chatroomID = ids.join('_');

    // Update the message to mark it as deleted
    await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .doc(messageID)
        .update({"messageDeleted": true}); // Marking the message as deleted

    notifyListeners();
  }

  // Check if message is deleted
  Future<bool> isMessageDeleted(
      String messageID, String senderID, String receiverID) async {
    List<String> ids = [senderID, receiverID];
    ids.sort(); // Sort IDs for the chatroomID
    String chatroomID = ids.join('_');

    // Get the specific message document
    DocumentSnapshot messageDoc = await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .doc(messageID)
        .get();

    // Check if the document exists and safely cast the data to Map<String, dynamic>
    final data = messageDoc.data() as Map<String, dynamic>?;

    // Return the deletion status or false if the document doesn't exist
    return data?['messageDeleted'] ?? false; // Default to false if not found
  }
}
