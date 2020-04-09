import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

class LoginOptionsPage extends StatefulWidget {
  static String routeName = '/login_with_phone_page';

  @override
  _LoginOptionsPageState createState() => _LoginOptionsPageState();
}

class _LoginOptionsPageState extends State<LoginOptionsPage> {
  bool showProgressIndicator = false;

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Firebase Authentication',
          style: TextStyle(
            color: Colors.deepPurple,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
              Container(
                child: Image.asset(
                  'assets/login.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SignInButton(
                Buttons.Google,
                text: 'Sign In With Google',
                onPressed: () async {
                  setState(() {
                    showProgressIndicator = true;
                  });

                  goToSignInWithGoogle(authService, context);

                  await Future.delayed(Duration(milliseconds: 1000)).then((_) async {
                    setState(() {
                      showProgressIndicator = false;
                    });
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.only(left: 30),
              ),
              SignInButtonBuilder(
                padding: EdgeInsets.only(left: 30),
                text: 'Sign In with Phone',
                icon: Icons.local_phone,
                onPressed: () {
                  authService.loginMode = LoginMode.loginWithPhone;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => authService.handleAuth()));
                },
                backgroundColor: Colors.cyan[700],
                width: 220.0,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
              ),
              SignInButtonBuilder(
                text: 'Sign In with Email',
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.only(left: 30),
                icon: Icons.email,
                onPressed: () {
                  authService.loginMode = LoginMode.loginWithEmailAndPassword;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => authService.handleAuth()));
                },
                backgroundColor: Colors.red,
                width: 220.0,
                height: 40,
              ),
              SignInButton(
                Buttons.Facebook,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.only(left: 30),
                onPressed: () async {
                  setState(() {
                    showProgressIndicator = true;
                  });

                  goToSignInWithFacebook(authService, context);

                  await Future.delayed(Duration(milliseconds: 1000)).then((_) async {
                    setState(() {
                      showProgressIndicator = false;
                    });
                  });
                },
              ),
              SignInButton(
                Buttons.Twitter,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.only(left: 30),
                onPressed: () async => goToSignInWithGoogle(authService, context),
              ),
              SizedBox(height: 10),
              Visibility(
                child: Center(child: CircularProgressIndicator()),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: showProgressIndicator,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> goToSignInWithGoogle(AuthService authService, BuildContext context) async {
    {
      authService.loginMode = LoginMode.loginWithGoogle;

      bool result = await authService.signInWithGoogle();
      if (!result) {
        return;
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => authService.handleAuth()));
    }
  }

  Future<void> goToSignInWithFacebook(AuthService authService, BuildContext context) async {
    {
      authService.loginMode = LoginMode.loginWithFacebook;

      bool result = await authService.signInWithFacebook();
      if (!result) {
        return;
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => authService.handleAuth()));
    }
  }
}
