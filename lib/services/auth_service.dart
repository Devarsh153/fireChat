import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/helper/helper_function.dart';
import 'package:firechat/services/database_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future registerWithEmail(
    String username,
    String email,
    String password,
  ) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        // add user to database
        await DatabaseService(uid: user.uid).SaveUserData(username, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      // print(e);
      return e.message;
    }
  }

  Future LoginUser(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future SignOut() async {
    try {
      await HelperFunction.saveUserEmail("");
      await HelperFunction.saveUserName("");
      await HelperFunction.saveUserLoggedInstatus(false);
      firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
