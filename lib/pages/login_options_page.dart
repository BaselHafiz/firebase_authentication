import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/pages/login_with_email_and_password_admins_page.dart';
import 'package:firebaseauthentication/pages/login_with_email_and_password_page.dart';
import 'package:firebaseauthentication/pages/login_with_phone_page.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:firebaseauthentication/services/user_database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

import 'normal_user_dashboard_page.dart';

class LoginOptionsPage extends StatefulWidget {
  static String routeName = '/login_options_page';

  @override
  _LoginOptionsPageState createState() => _LoginOptionsPageState();
}

class _LoginOptionsPageState extends State<LoginOptionsPage> {
  UserDatabaseService userDatabaseService;
  AuthService authService;

  @override
  Widget build(BuildContext context) {
    authService = Provider.of<AuthService>(context, listen: false);
    userDatabaseService = Provider.of<UserDatabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Authentication', style: TextStyle(color: Colors.deepPurple, fontSize: 18)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
              Container(
                child: Image.asset('assets/login.png', height: 150, width: 150, fit: BoxFit.cover),
              ),
              SizedBox(height: 30),
              SignInButton(
                Buttons.Google,
                text: 'Sign In With Google',
                onPressed: () async {
                  if (await DataConnectionChecker().hasConnection) {
                    if (await authService.signInWithGoogle(context)) {
                      FirebaseUser currentUser = await authService.currentFirebaseUser;

                      if (!await userDatabaseService.isEmailExist(currentUser, context)) {
                        userDatabaseService.insertNewUser(
                            firebaseUser: currentUser, loginMode: LoginMode.loginWithGoogle);
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NormalUserDashboardPage(
                            user: currentUser,
                            loginMode: LoginMode.loginWithGoogle,
                          ),
                        ),
                      );
                    }
                  } else {
                    authService.notifyUser('No Internet connection.', context);
                  }
                },
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                padding: EdgeInsets.only(left: 30),
              ),
              SignInButtonBuilder(
                padding: EdgeInsets.only(left: 30),
                text: 'Sign In with Phone',
                icon: Icons.local_phone,
                onPressed: () {
                  Navigator.pushNamed(context, LoginWithPhonePage.routeName);
                },
                backgroundColor: Colors.cyan[700],
                width: 220.0,
                height: 40,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
              ),
              SignInButtonBuilder(
                text: 'Sign In with Email',
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                padding: EdgeInsets.only(left: 30),
                icon: Icons.email,
                onPressed: () {
                  Navigator.pushNamed(context, LoginWithEmailAndPasswordPage.routeName);
                },
                backgroundColor: Colors.red,
                width: 220.0,
                height: 40,
              ),
              SignInButton(
                Buttons.Facebook,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                padding: EdgeInsets.only(left: 30),
                onPressed: () async {
                  if (await DataConnectionChecker().hasConnection) {
                    if (await authService.signInWithFacebook(context)) {
                      FirebaseUser currentUser = await authService.currentFirebaseUser;

                      if (!await userDatabaseService.isEmailExist(currentUser, context)) {
                        userDatabaseService.insertNewUser(
                            firebaseUser: currentUser, loginMode: LoginMode.loginWithFacebook);
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NormalUserDashboardPage(
                            user: currentUser,
                            loginMode: LoginMode.loginWithFacebook,
                          ),
                        ),
                      );
                    }
                  } else {
                    authService.notifyUser('No Internet connection.', context);
                  }
                },
              ),
              SignInButton(
                Buttons.Twitter,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                padding: EdgeInsets.only(left: 30),
                onPressed: () async {
                  bool result = await authService.signInWithFacebook(context);

                  if (!result) {
                    return;
                  }
                },
              ),
              FlatButton(
                  child: Text(
                    'Sign In for Admins',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginWithEmailAndPasswordAdminsPage.routeName);
                  }),
              SizedBox(height: 15),
              Consumer<AuthService>(
                builder: (context, auth, _) => Visibility(
                  child: Center(child: CircularProgressIndicator()),
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  visible: auth.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
