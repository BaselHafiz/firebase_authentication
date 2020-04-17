import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/normal_user_dashboard_page.dart';

class UserDatabaseService with ChangeNotifier {
  Future<void> insertNewUser({FirebaseUser firebaseUser, LoginMode loginMode}) async {
    switch (loginMode) {
      case LoginMode.loginWithPhone:
        await Firestore.instance.collection('/users').add({
          'userUid': firebaseUser.uid,
          'userPhoneNumber': firebaseUser.phoneNumber,
          'userLoginMode': 'phone',
          'roles': {
            'isAdmin': false,
          },
        });
        break;

      case LoginMode.loginWithEmailAndPassword:
        await Firestore.instance.collection('/users').add({
          'userUid': firebaseUser.uid,
          'userEmail': firebaseUser.email,
          'userLoginMode': 'emailAndPassword',
          'roles': {
            'isAdmin': false,
          },
        });
        break;

      case LoginMode.loginWithFacebook:
        await Firestore.instance.collection('/users').add({
          'userUid': firebaseUser.uid,
          'userEmail': firebaseUser.email,
          'userPhotoUrl': firebaseUser.photoUrl,
          'userDisplayName': firebaseUser.displayName,
          'userLoginMode': 'facebook',
          'roles': {
            'isAdmin': false,
          },
        });
        break;

      case LoginMode.loginWithGoogle:
        await Firestore.instance.collection('/users').add({
          'userUid': firebaseUser.uid,
          'userEmail': firebaseUser.email,
          'userPhotoUrl': firebaseUser.photoUrl,
          'userDisplayName': firebaseUser.displayName,
          'userLoginMode': 'google',
          'roles': {
            'isAdmin': false,
          },
        });
        break;
    }
  }

  // ignore: missing_return
  Future<bool> isAdmin(FirebaseUser currentUser, BuildContext context) async {
    final QuerySnapshot snapshot =
        await Firestore.instance.collection('/users').where('userUid', isEqualTo: currentUser.uid).getDocuments();

    try {
      if (snapshot.documents[0].data['roles']['isAdmin']) {
        return true;
      } else {
        notifyUser('You are not an Admin', context);
        return false;
      }
    } catch (error) {
      notifyUser(error.message.toString(), context);
      return false;
    }
  }

  Future<bool> isPhoneExist(FirebaseUser currentUser, BuildContext context) async {
    final QuerySnapshot snapshot = await Firestore.instance
        .collection('/users')
        .where('userPhoneNumber', isEqualTo: currentUser.phoneNumber)
        .getDocuments();

    try {
      if (snapshot.documents.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (error) {
      notifyUser(error.message.toString(), context);
    }
  }

  Future<bool> isEmailExist(FirebaseUser currentUser, BuildContext context) async {
    final QuerySnapshot snapshot =
        await Firestore.instance.collection('/users').where('userEmail', isEqualTo: currentUser.email).getDocuments();

    try {
      if (snapshot.documents.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (error) {
      notifyUser(error.message.toString(), context);
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
