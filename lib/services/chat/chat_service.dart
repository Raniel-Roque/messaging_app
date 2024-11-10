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
      // Get blocked user IDs
      final blockedUserIDs = snapshot.docs.map((doc) => doc.id).toList();

      // Get all users
      final usersSnapshot = await _firestore.collection('Users').get();

      // Return filtered list: only users with the 'user' role and not blocked
      return usersSnapshot.docs
          .where((doc) {
            final userData = doc.data();
            final role =
                userData['role']; // Assuming role is stored under 'role'

            // Only include users with 'user' role and not blocked
            return role == 'user' &&
                doc.id != currentUser.uid && // Exclude current user
                !blockedUserIDs.contains(doc.id); // Exclude blocked users
          })
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

  //Admin Stuff

  // Delete a specific report
  Future<void> deleteReport(String reportID) async {
    try {
      // Delete the report from Firestore
      await _firestore.collection('Reports').doc(reportID).delete();
      notifyListeners(); // Notify listeners to refresh the data
    } catch (e) {
      print("Error deleting report: $e");
      rethrow; // Rethrow error if needed for further handling
    }
  }

  // Get Reports Stream
  Stream<List<Map<String, dynamic>>> getReportedUsersStream() {
    return _firestore.collection('Reports').snapshots().asyncMap(
      (snapshot) async {
        final reportDocs = snapshot.docs;

        // Retrieve data for each report document
        final reportsData = await Future.wait(
          reportDocs.map((doc) async {
            final reportData = doc.data();

            // Get the report ID (doc.id)
            final reportID = doc.id;

            // Fetch the user details of the 'reportedBy' user (the one who reported)
            final reportedByUserID = reportData['reportedBy'];
            final reportedByUserDoc = await _firestore
                .collection('Users')
                .doc(reportedByUserID)
                .get();
            final reportedByUserData =
                reportedByUserDoc.data() as Map<String, dynamic>;

            // Fetch the message ID and message owner details
            final messageOwnerID = reportData['messageOwnerID'];
            final messageID = reportData['messageID'];

            final messageOwnerUserDoc =
                await _firestore.collection('Users').doc(messageOwnerID).get();
            final messageOwnerUserData =
                messageOwnerUserDoc.data() as Map<String, dynamic>;

            // Construct chatroom ID for the 2 users who are involved in the reported message
            List<String> ids = [reportedByUserID, messageOwnerID];
            ids.sort(); // Sorts IDs which ensures 2 people have the same chatroomID
            String chatroomID = ids.join('_');

            // Fetch the actual message content from the correct chatroom and message
            final messageDoc = await _firestore
                .collection('chat_rooms')
                .doc(
                    chatroomID) // Use the chatroomID constructed from reportedByUserID and messageOwnerID
                .collection('messages')
                .doc(messageID)
                .get();

            final messageContent = messageDoc.exists
                ? messageDoc.data()!['message'] // Retrieve the message content
                : 'Message not found';

            // Combine the report data with user data (reportedBy, messageOwner, and message content)
            return {
              'report': reportData, // Original report details
              'reportID': reportID, // Add the report ID
              'reportedByUser':
                  reportedByUserData, // Data of the user who reported
              'messageOwnerUser':
                  messageOwnerUserData, // Data of the user who owned the message
              'messageContent': messageContent, // The actual message content
            };
          }),
        );

        return reportsData;
      },
    );
  }
}
