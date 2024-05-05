import 'package:firebase_core/firebase_core.dart';
import 'package:firechat/pages/SplashScreen.dart';
import 'package:firechat/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   if (kIsWeb) {
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: Constants.apiKey,
          appId: Constants.appId,
          messagingSenderId: Constants.messagingSenderId,
          projectId: Constants.projectId));
  //   } else {
  // await Firebase.initializeApp();
  //   }
  // } catch (e) {
  //   print('Error initializing Firebase: $e');
  //   // Handle error accordingly
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Constants().primaryColor,
        ),
        debugShowCheckedModeBanner: false,
        home: SplashScreen());
  }
}
