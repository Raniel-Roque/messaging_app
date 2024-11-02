import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late final String senderID;
  late final String senderEmail;
  late final String receiverID;
  late final String message;
  late final Timestamp timestamp;
  late final bool messageDeleted;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.messageDeleted = false,
  });

  //Covert to map

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': receiverID,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'messageDeleted': messageDeleted,
    };
  }
}
