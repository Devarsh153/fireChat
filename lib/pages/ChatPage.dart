import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firechat/helper/navigation_function.dart';
import 'package:firechat/pages/GroupInfo.dart';
import 'package:firechat/pages/MessageTile.dart';
import 'package:firechat/services/database_service.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupID;
  final String groupName;
  final String userName;
  const ChatPage(
      {super.key,
      required this.groupID,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream? chats;
  String adminName = "";
  TextEditingController msgController = TextEditingController();
  void initState() {
    getAdmin();
  }

  void getAdmin() {
    DatabaseService().getAdmin(widget.groupID).then((value) {
      setState(() {
        adminName = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      grpID: widget.groupID,
                      grpName: widget.groupName,
                      admin: adminName,
                      userName: widget.userName,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: [
          chatsConatiner(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: TextField(
                    cursorColor: Colors.grey,
                    controller: msgController,
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        hintText: 'Type Message..',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                        filled: true,
                        fillColor: Colors.grey[200]),
                  )),
                  const SizedBox(
                    width: 14,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: CircleAvatar(
                      radius: 25,
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 28,
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  )
                ]),
          )
        ],
      ),
    );
  }

  chatsConatiner() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupID)
            .collection('messages')
            .orderBy('time')
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return MessageTile(
                    message: snapshot.data.docs[index]['message'],
                    sender: snapshot.data.docs[index]['sender'],
                    sentByMe:
                        widget.userName == snapshot.data.docs[index]['sender']);
              },
            );
          } else {
            return Container(child: Center(child: Text('snap is empty')));
          }
        });
  }

  sendMessage() {
    if (msgController.text.isNotEmpty) {
      Map<String, dynamic> msgData = {
        'message': msgController.text,
        'sender': widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch
      };

      DatabaseService().sendMessage(widget.groupID, msgData);
      setState(() {
        msgController.clear();
      });
    } else {
      print('eerror');
    }
  }
}
