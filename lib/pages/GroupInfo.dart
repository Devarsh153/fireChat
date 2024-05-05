import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firechat/helper/navigation_function.dart';
import 'package:firechat/services/database_service.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String grpName;
  final String admin;
  final String grpID;
  final String userName;
  const GroupInfo(
      {super.key,
      required this.grpName,
      required this.grpID,
      required this.userName,
      required this.admin});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? member;
  @override
  void initState() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getMember(widget.grpID)
        .then((val) {
      setState(() {
        member = val;
      });
    });
  }

  String getMemberName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  String getMemberId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () async {
                await DatabaseService(
                        uid: FirebaseAuth.instance.currentUser!.uid)
                    .exitGroup(widget.grpID, widget.grpName, widget.userName)
                    .then((value) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Exited from the group'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                  },
                                  child: const Text('Ok'))
                            ],
                          ));
                });
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 60,
              ),
              const CircleAvatar(
                child: Icon(
                  Icons.group,
                  size: 60,
                  color: Colors.grey,
                ),
                radius: 80,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.grpName,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Members',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey[800]),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                // margin: EdgeInsets.only(left: 10),
                width: MediaQuery.of(context).size.width,
                height: 340,
                child: memberList(),
              ),
            ],
          )
        ],
      ),
    );
  }

  memberList() {
    return StreamBuilder(
        stream: member,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          } else {
            if (snapshot.hasData) {
              if (snapshot.data.data() != null) {
                List<dynamic> members = snapshot.data?.data()?['members'] ?? [];
                if (members.isNotEmpty) {
                  // return Text('gfound');
                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                        ),
                        title: Text(
                          getMemberName(members[index]),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: members[index] == widget.admin
                            ? const Text('Admin')
                            : const Text(''),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No members..:( '));
                }
              } else {
                // 'groups' field does not exist or is null
                return const Center(child: Text('No members yet'));
              }
            } else {
              return Text('No Member Found :( ');
            }
          }
        });
  }
}
