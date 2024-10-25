import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Message {
  late final String senderID;
  late final String senderEmail;
  late final String receiverID;
  late final String message;
  late final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });

  //Covert to map

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': receiverID,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
