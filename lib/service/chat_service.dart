import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore firstore = FirebaseFirestore.instance;
  final FirebaseAuth fireauth = FirebaseAuth.instance;

  String getChaatRoomid(String user1, String user2) {
    List ids = [user1, user2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> sendMessage(String message, String Reciverid) async {
    final currentUser = fireauth.currentUser;
    if (currentUser == null || message.isEmpty) return;

    String chatRoomIdc = getChaatRoomid(currentUser.uid, Reciverid);

    await firstore
        .collection("chat_rooms")
        .doc(chatRoomIdc)
        .collection("messages")
        .add({
          "sender": currentUser.uid,
          "reciver": Reciverid,
          "messages": message,
          "timetamp": Timestamp.now(),
        });
  }

  Stream<QuerySnapshot> getMessage(String reciverId) {
    final currentUser = fireauth.currentUser;

    String chaatroomid = getChaatRoomid(currentUser!.uid, reciverId);
    return firstore
        .collection("chat_rooms")
        .doc(chaatroomid)
        .collection("messages")
        .orderBy("timetamp", descending: true)
        .snapshots();
  }
}
