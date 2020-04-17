import 'dart:async';
import 'package:rxdart/subjects.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String errorMessage;
  PublishSubject<bool> userSubject = PublishSubject();
  bool isLoading = false;

  Future<bool> signOut(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      await auth.signOut();
      isLoading = false;
      notifyListeners();
    } catch (error) {
      notifyUser(error.message.toString(), context);
      isLoading = false;
      notifyListeners();
      return false;
    }
    userSubject.add(false);
    return true;
  }

  Future<FirebaseUser> get currentFirebaseUser async {
    FirebaseUser currentUser;
    while (currentUser == null) {
      currentUser = await auth.currentUser();
    }
    notifyListeners();
    return currentUser;
  }

  Future<void> autoAuthenticate() async {
    FirebaseUser currentUser;
    int counter = 0;
    while (currentUser == null && counter <= 500) {
      currentUser = await auth.currentUser();
      counter++;
    }

    if (currentUser != null) {
      final QuerySnapshot snapshot =
          await Firestore.instance.collection('/users').where('userUid', isEqualTo: currentUser.uid).getDocuments();

      if (snapshot.documents[0].data['roles']['isAdmin']) {
        await auth.signOut();
      } else {
        userSubject.add(true);
      }
    }
  }

  Future<bool> signIn(AuthCredential authCred, BuildContext context, {smsCode}) async {
    try {
      isLoading = true;
      notifyListeners();
      AuthResult authResult = await auth.signInWithCredential(authCred);
      if (authResult.user == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      if (smsCode == null || smsCode == '') {
        notifyUser('The SMS Code could not be empty.', context);
      } else {
        notifyUser(error.message.toString(), context);
      }
      isLoading = false;
      notifyListeners();
      return false;
    }
    userSubject.add(true);
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signInWithOTP(smsCode, verId, context) async {
    try {
      AuthCredential authCred = PhoneAuthProvider.getCredential(verificationId: verId, smsCode: smsCode);
      if (await signIn(authCred, context, smsCode: smsCode)) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      notifyUser(error.message.toString(), context);
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      AuthResult authResult = await auth.signInWithEmailAndPassword(email: email, password: password);
      if (authResult.user == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      notifyUser(error.message.toString(), context);
      isLoading = false;
      notifyListeners();
      return false;
    }
    userSubject.add(true);
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      AuthResult authResult = await auth.createUserWithEmailAndPassword(email: email, password: password);
      if (authResult.user == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      notifyUser(error.message.toString(), context);
      isLoading = false;
      notifyListeners();
      return false;
    }
    userSubject.add(true);
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      GoogleSignInAccount account = await GoogleSignIn().signIn();
      if (account == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      AuthResult authResult = await auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken,
      ));

      if (authResult.user == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }
      userSubject.add(true);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      notifyUser(error.message.toString(), context);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      var facebookLogin = FacebookLogin();
      var result = await facebookLogin.logIn(['email']);

      if (result == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
          AuthResult authResult = await auth.signInWithCredential(credential);

          if (authResult.user == null) {
            isLoading = false;
            notifyListeners();
            return false;
          }
          break;
        case FacebookLoginStatus.cancelledByUser:
          isLoading = false;
          notifyListeners();
          return false;
        case FacebookLoginStatus.error:
          isLoading = false;
          notifyListeners();
          return false;
      }
      userSubject.add(true);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      notifyUser(error.message.toString(), context);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Widget> notifyUser(String message, BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        title: Text('Error Occurred', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text('$message', style: TextStyle(fontSize: 18)),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
