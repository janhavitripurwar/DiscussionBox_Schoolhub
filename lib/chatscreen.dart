import 'dart:io';
import 'package:chatboxschoolhub/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'imagecapture.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:firebase_storage/firebase_storage.dart'; // For File Upload To Firestore
import 'package:path/path.dart';


class chatscreen extends StatefulWidget {
  @override
  _chatscreenState createState() => _chatscreenState();
}

class _chatscreenState extends State<chatscreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();

  Stream chatMessageStream;

  Widget ChatMessageList(){
    ScrollController _scrollController;

    return StreamBuilder(
        stream: chatMessageStream,
        builder: (context,snapshot){
          return snapshot.hasData? ListView.builder(
            controller: _scrollController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index){
                return MessageTile(snapshot.data.documents[index]["message"]);
              }
          ) : Container();
        }
    );
  }

  sendMessage(){
    if(messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
       // "sendBy": Constants.myName,
        "time" : DateTime.now().millisecondsSinceEpoch
      };
      databaseMethods.addConversationMessages(messageMap);
      messageController.text = "";
    }
  }
    File imageFile;
  pickImageFromGallery(ImageSource source)async{
    final pickedImageFile = await ImagePicker().getImage(source: source);
    setState(() {
      imageFile=File(pickedImageFile.path);
    });
    upload(this.context);
    print("donedonedone");
  }
  upload(BuildContext context)async{
    print("notyetnotyet");
    String filename = basename(imageFile.path);
    Reference firebaseStorageRef =  FirebaseStorage.instance.ref().child('gs://chatboxschoolhub.appspot.com/images');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    // TaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String url = imageUrl.toString();
    print("jjjjjjjjjjjjjjjjjjjjjjjjjj");
    print(url);
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages().then((value){
      setState(() {
        chatMessageStream=value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
         // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'Images/Vector.png',
              //fit: BoxFit.contain,
            ),
            SizedBox(width: 60),
            Text('Discussion Box',style: TextStyle(
              fontSize: 28
            ),),
            SizedBox(width: 60,),
            Image.asset(
              'Images/favicon 1.png',
            )
          ],
        ),
        ),
      body:Container(
        child: Stack(
            children: [
              ChatMessageList(),
              Container(
                alignment: Alignment.bottomCenter ,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  height: MediaQuery.of(context).size.height-100,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 10,),
                        Image.asset('Images/favicon 1.png'),
                        SizedBox(width: 7,),
                        GestureDetector(
                            onTap: (){
                              // Navigator.push(context, MaterialPageRoute(
                              //     builder: (context) => PickImageDemo()
                             // ));
                              pickImageFromGallery(ImageSource.gallery);
                            },
                            child: Image.asset('Images/Vector.png')),
                        SizedBox(width: 20,),
                        Expanded(
                            child: TextField(
                              controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'message'
                          ),
                        )),
                        GestureDetector(
                            onTap: (){
                              //getImageFile(ImageSource.gallery);
                              sendMessage();
                            },
                            child: Icon(Icons.send)),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
      )
      );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  MessageTile(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xff007EF4),
              const Color(0xff2A75BC)
            ]
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
            bottomLeft: Radius.circular(23)
          )
        ),
        child: Text(message,style: TextStyle(color: Colors.white,fontSize: 17),),
      ),
    );
  }
}
