import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/helper/helper_function.dart';
import 'package:firechat/helper/navigation_function.dart';
import 'package:firechat/pages/ChatPage.dart';
import 'package:firechat/pages/LoginPage.dart';
import 'package:firechat/pages/Profile_Page.dart';
import 'package:firechat/pages/SearchPage.dart';
import 'package:firechat/pages/SplashScreen.dart';
import 'package:firechat/services/auth_service.dart';
import 'package:firechat/services/database_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  @override
  String userName = "";
  Stream? groups;
  String grpName = "";
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

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroup()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  String getGrpID(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getGrpName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('FireChat'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(context, const SearchPage());
                },
                icon: Icon(
                  Icons.search,
                ))
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 60),
            children: [
              Icon(
                Icons.account_circle,
                color: Colors.grey[500],
                size: 120,
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'Devarshi Mistri',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                onTap: () {
                  nextScreen(context, Profile_Page());
                },
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Profile'),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                leading: Icon(
                  Icons.group,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Groups'),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Log Out'),
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text('Are you sure you want to logout ?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancle')),
                            TextButton(
                                onPressed: () {
                                  authService.SignOut();
                                  nextScreenReplace(context, SplashScreen());
                                },
                                child: const Text('Log Out'))
                          ],
                        );
                      });
                },
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            popUp();
          },
          elevation: 0,
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: gropList());
  }

  gropList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          } else {
            if (snapshot.hasData) {
              // Check if the 'groups' field exists and is not null

              if (snapshot.data.data() != null) {
                List<dynamic> groups = snapshot.data?.data()?['groups'] ?? [];
                if (groups.isNotEmpty && groups != null && groups.isNotEmpty) {
                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          nextScreen(
                              context,
                              ChatPage(
                                  groupID: getGrpID(groups[index]),
                                  groupName: getGrpName(groups[index]),
                                  userName: userName));
                        },
                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.group,
                            color: Colors.grey,
                          ),
                        ),
                        title: Text(
                          getGrpName(groups[index]),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: const Text(
                          "join the group to chat",
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No Groups..:( '));
                }
              } else {
                // 'groups' field does not exist or is null
                return const Center(child: Text('No groups yet'));
              }
            } else {
              // DocumentSnapshot does not exist
              return const Center(child: Text('Document does not exist'));
            }
          }
        });
  }

  popUp() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Create Group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      grpName = value;
                    });
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10)),
                      errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10))),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  )),
              TextButton(
                  onPressed: () {
                    if (grpName != "") {
                      DatabaseService(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGropus(userName,
                              FirebaseAuth.instance.currentUser!.uid, grpName)
                          .whenComplete(() {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ))
            ],
          );
        });
  }
}
