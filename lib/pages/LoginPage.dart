import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firechat/helper/helper_function.dart';
import 'package:firechat/helper/navigation_function.dart';
import 'package:firechat/pages/HomePage.dart';
import 'package:firechat/pages/RegisterPage.dart';
import 'package:firechat/pages/SplashScreen.dart';
import 'package:firechat/services/auth_service.dart';
import 'package:firechat/services/database_service.dart';
import 'package:firechat/shared/constants.dart';
import 'package:firechat/widgets/cutomInput.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoadding = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoadding
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 57),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'FireChat',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Login with your credential to chat.'),
                          const SizedBox(
                            height: 60,
                          ),
                          Image.asset(
                            'assets/chat.jpg',
                            scale: .5,
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          TextFormField(
                            decoration: customInputStyle.copyWith(
                              labelText: 'Email',
                              prefixIcon: Icon(
                                Icons.email,
                                color: Constants().primaryColor,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                            validator: (value) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value!)
                                  ? null
                                  : 'please enter valid email';
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: customInputStyle.copyWith(
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Constants().primaryColor,
                              ),
                            ),
                            validator: (value) {
                              if (value!.length < 6) {
                                return "password must be atleast 6 character";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () {
                                  login();
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text.rich(TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                    text: 'Register here',
                                    style: TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        nextScreen(context, RegisterPage());
                                      })
                              ]))
                        ],
                      )),
                ),
              ));
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadding = true;
      });
      await AuthService().LoginUser(email, password).then((value) async {
        if (value == true) {
          QuerySnapshot snap =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getUSerData(email);
          await HelperFunction.saveUserLoggedInstatus(true);
          await HelperFunction.saveUserEmail(email);
          await HelperFunction.saveUserName(snap.docs[0]["username"]);
          nextScreenReplace(context, HomePage());
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(value),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Ok'))
                    ],
                  ));
          setState(() {
            _isLoadding = false;
          });
        }
      });
    }
  }
}
