import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{

  addConversationMessages(messageMap){
     FirebaseFirestore.instance.collection("chats")
        .add(messageMap).catchError((e){print(e.toString());
    });
  }
  getConversationMessages() async{
    return await FirebaseFirestore.instance.collection("chats")
    .orderBy("time",descending: false)
    .snapshots();
  }
}