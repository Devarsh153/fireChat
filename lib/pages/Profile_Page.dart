import 'package:firechat/helper/navigation_function.dart';
import 'package:firechat/pages/LoginPage.dart';
import 'package:flutter/material.dart';

class Profile_Page extends StatefulWidget {
  const Profile_Page({super.key});

  @override
  State<Profile_Page> createState() => _Profile_PageState();
}

class _Profile_PageState extends State<Profile_Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/pro.jpg'),
              ),
              SizedBox(height: 10),
              Text(
                'Devarshi Mistri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 100,
              ),
              ListTile(
                leading: Icon(
                  Icons.mail,
                  size: 25,
                ),
                title: Text(
                  'dev@gmail.com',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  size: 25,
                ),
                title: Text(
                  '8837292829',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  size: 30,
                ),
                title: Text(
                  'Setting',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () {
                  nextScreenReplace(context, LoginPage());
                },
                leading: Icon(
                  Icons.logout,
                  size: 30,
                ),
                title: Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
