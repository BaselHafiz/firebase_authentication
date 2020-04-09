import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/pages/dashboard_page.dart';
import 'package:firebaseauthentication/pages/login_options_page.dart';
import 'package:firebaseauthentication/pages/login_with_email_and_password_page.dart';
import 'package:firebaseauthentication/pages/login_with_phone_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum LoginMode {
  loginWithPhone,
  loginWithEmailAndPassword,
  loginWithGoogle,
  loginWithFacebook,
  noLoginOptionChosen,
}

class AuthService with ChangeNotifier {
  bool isLoading = false;
  LoginMode loginMode = LoginMode.noLoginOptionChosen;
  AuthResult authResult;
  String signedInUserUid;
  String signedInUserEmail;
  String signedInUserGoogleEmail;
  String signedInUserGoogleProfilePhotoUrl;
  String signedInUserFacebookEmail;
  String signedInUserFacebookProfilePhotoUrl;

  Stream<String> get onAuthStateChanged {
    return FirebaseAuth.instance.onAuthStateChanged.map((FirebaseUser user) => user?.uid);
  }

  StreamBuilder<String> handleAuth() {
    getCurrentUserUid();
    getCurrentUserEmail();

    return StreamBuilder<String>(
      stream: onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return DashboardPage(
            userUid: signedInUserUid,
            userEmail: signedInUserEmail,
            userGoogleEmail: signedInUserGoogleEmail,
            userGoogleProfilePhotoUrl: signedInUserGoogleProfilePhotoUrl,
            userFacebookEmail: signedInUserFacebookEmail,
            userFacebookProfilePhotoUrl: signedInUserFacebookProfilePhotoUrl,
          );
        } else {
          switch (loginMode) {
            case LoginMode.loginWithPhone:
              return LoginWithPhonePage();
            case LoginMode.loginWithEmailAndPassword:
              return LoginWithEmailAndPasswordPage();
            default:
              return LoginOptionsPage();
          }
        }
      },
    );
  }

  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 500)).then((_) async {
      await FirebaseAuth.instance.signOut();
    });

    isLoading = false;
    signedInUserUid = null;
    signedInUserEmail = null;
    signedInUserGoogleEmail = null;
    signedInUserGoogleProfilePhotoUrl = null;
    signedInUserFacebookEmail = null;
    signedInUserFacebookProfilePhotoUrl = null;

    notifyListeners();
  }

  Future<void> signIn(AuthCredential authCred) async {
    isLoading = true;
    notifyListeners();
    try {
      authResult = await FirebaseAuth.instance.signInWithCredential(authCred);
    } catch (error) {
      print('Error: ${error.toString()}');
    }
    isLoading = false;
    notifyListeners();
  }

  void signInWithOTP(smsCode, verId) async {
    AuthCredential authCred = PhoneAuthProvider.getCredential(verificationId: verId, smsCode: smsCode);
    await signIn(authCred);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      print('Error: ${error.toString()}');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      print('Error: ${error.toString()}');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentUserUid() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    signedInUserUid = user?.uid;
  }

  Future<void> getCurrentUserEmail() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    signedInUserEmail = user?.email;
  }

  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignInAccount account = await GoogleSignIn().signIn();
      if (account == null) {
        return false;
      }

      AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken,
      ));

      if (authResult.user == null) {
        return false;
      }

      signedInUserGoogleEmail = authResult.user.email;
      signedInUserGoogleProfilePhotoUrl = authResult.user.photoUrl;

      return true;
    } catch (error) {
      print('Error in logging with Google');
      print(error);
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    try {
      var facebookLogin = FacebookLogin();
      var result = await facebookLogin.logIn(['email']);

      if (result == null) {
        return false;
      }

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
          AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);

          if (authResult.user == null) {
            return false;
          }

          signedInUserFacebookEmail = authResult.user.email;
          signedInUserFacebookProfilePhotoUrl = authResult.user.photoUrl;
          return true;
        case FacebookLoginStatus.cancelledByUser:
          return false;
        case FacebookLoginStatus.error:
          return false;
      }

      return true;
    } catch (error) {
      print('Error in logging with Facebook');
      print(error);
      return false;
    }
  }
}
