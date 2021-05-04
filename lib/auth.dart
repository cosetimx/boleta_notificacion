import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<User> currentUser();
  Future<String> signIn(String email, String password);
  Future<String> createUser(String email, String password);
  Future<void> signOut();
  Future<String> getEmail();
  Future<bool> isEmailVerified();
  Future<void> resetPassword(String email);
  Future<void> sendEmailVerification();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    final UserCredential user =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return  user.user.uid;  // authResult.user.uid;
  }

  Future<String> createUser(String email, String password) async {
    final UserCredential authResult = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    // FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return authResult.user.uid;
  }

  Future<User> currentUser() async {
    User user = await _firebaseAuth.currentUser;
   // print("uid ${user.uid}");
    return user;
  }

  Future<String> getEmail() async {
    User user = await _firebaseAuth.currentUser;
    return user.email;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<bool> isEmailVerified() async {
    User user = await _firebaseAuth.currentUser;
    print('Is Verified ${user.uid.isNotEmpty}');
    return user.uid.isNotEmpty;
  }

  Future<void> resetPassword(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    User user = await _firebaseAuth.currentUser;
    return user.sendEmailVerification();
  }
}
