import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/helper/helper_function.dart';
import 'package:firechat/helper/navigation_function.dart';
import 'package:firechat/pages/ChatPage.dart';
import 'package:firechat/services/database_service.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool isjoined = false;
  late QuerySnapshot<Object?> searchSnap;
  bool isUserSearched = false;
  String userName = "";

  void initState() {
    super.initState();
    getUser();
  }

  Future getUser() async {
    await HelperFunction.getUserName().then((value) {
      setState(() {
        userName = value;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 340,
                    margin: EdgeInsets.only(top: 20),
                    child: TextField(
                      onChanged: (value) {
                        // Future.delayed(Duration(seconds: 2), () {
                        search();
                        // });
                      },
                      controller: searchController,
                      autofocus: true,
                      cursorHeight: 20,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Serach Groups',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 1),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none)),
                          filled: true,
                          fillColor: Colors.grey[200]),
                      cursorColor: Colors.grey,
                    ))
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 600,
                    child: grpList(),
                  )
          ],
        ),
      ),
    );
  }

  search() async {
    setState(() {
      isLoading = true;
    });
    if (searchController.text.isNotEmpty) {
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .searchByName(searchController.text)
          .then((val) {
        setState(() {
          searchSnap = val;
          isLoading = false;
          isUserSearched = true;
        });
      });
    } else {
      setState(() {
        isLoading = false;
        isUserSearched = false;
      });
    }
  }

  joinedOrNot(String groupId, String groupName) async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .isUserJoined(groupId, groupName)
        .then((value) {
      setState(() {
        isjoined = value;
      });
    });
  }

  grpList() {
    return isUserSearched
        ? ListView.builder(
            itemCount: searchSnap.docs.length,
            itemBuilder: (context, index) {
              var group = searchSnap.docs[index];
              joinedOrNot(group['groupId'], group['groupName']);
              return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.group,
                      color: Colors.grey,
                    ),
                  ),
                  title: Text(group['groupName']),
                  subtitle: const Text(
                    'Description about this group',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: InkWell(
                      onTap: () async {
                        await DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .toggleGroupJoin(
                                group['groupId'], group['groupName'], userName)
                            .then((value) {
                          if (isjoined) {
                            setState(() {
                              isjoined = false;
                            });
                            nextScreenReplace(
                                context,
                                ChatPage(
                                    groupID: group['groupId'],
                                    groupName: group['groupName'],
                                    userName: userName));
                          } else {
                            setState(() {
                              isjoined = false;
                            });
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('Removed from group'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Ok'))
                                      ],
                                    ));
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: isjoined
                            ? const Text(
                                'exit group',
                                style: TextStyle(color: Colors.white),
                              )
                            : const Text(
                                'Join Now',
                                style: TextStyle(color: Colors.white),
                              ),
                      ))

                  // Customize the ListTile as per your requirement
                  );
            },
          )
        : Container();
  }
}
