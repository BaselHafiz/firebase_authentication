import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:firebaseauthentication/services/user_database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'normal_user_dashboard_page.dart';

class LoginWithPhonePage extends StatefulWidget {
  static String routeName = '/login_with_phone_page';

  @override
  _LoginWithPhonePageState createState() => _LoginWithPhonePageState();
}

class _LoginWithPhonePageState extends State<LoginWithPhonePage> {
  String phoneNo;
  String smsCode;
  bool codeSent = false;
  String verificationId;
  AuthService authService;
  UserDatabaseService userDatabaseService;

  @override
  Widget build(BuildContext context) {
    authService = Provider.of<AuthService>(context, listen: false);
    userDatabaseService = Provider.of<UserDatabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Authentication', style: TextStyle(color: Colors.deepPurple, fontSize: 18)),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                    decoration: InputDecoration(hintText: 'Enter phone number with country code'),
                    onChanged: (value) {
                      setState(() {
                        phoneNo = value;
                      });
                    }),
              ),
              SizedBox(height: 10),
              codeSent
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextField(
                          decoration: InputDecoration(hintText: 'Enter OTP'),
                          onChanged: (value) {
                            setState(() {
                              smsCode = value;
                            });
                          }),
                    )
                  : Container(),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: RaisedButton(
                  textColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                  color: Colors.cyan,
                  elevation: 7,
                  child: codeSent
                      ? Text('Login', style: TextStyle(fontSize: 16, color: Colors.deepPurple))
                      : Text('Verify', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  onPressed: () async {
                    if (await DataConnectionChecker().hasConnection) {
                      if (codeSent) {
                        if (await authService.signInWithOTP(smsCode, verificationId, context)) {
                          FirebaseUser currentUser = await authService.currentFirebaseUser;
                          if (!await userDatabaseService.isPhoneExist(currentUser, context)) {
                            userDatabaseService.insertNewUser(
                                firebaseUser: currentUser, loginMode: LoginMode.loginWithPhone);
                          }
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NormalUserDashboardPage(
                                      user: currentUser,
                                      loginMode: LoginMode.loginWithPhone,
                                    )),
                          );
                        }
                      } else {
                        if (phoneNo != null) {
                          await verifyPhone(phoneNo, context);
                        } else {
                          authService.notifyUser('The phone number could not be empty.', context);
                        }
                      }
                    } else {
                      authService.notifyUser('No Internet connection.', context);
                    }
                  },
                ),
              ),
              SizedBox(height: 25),
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

  Future<bool> verifyPhone(String phoneNumber, BuildContext context) async {
    // This method is called after the timeout duration specified to verifyPhoneNumber has passed without onVerificationCompleted triggering first.
    // On devices without SIM cards, this method is called immediately because SMS auto-retrieval isn't possible.

    final autoRetrieve = (String verId) {
      setState(() {
        verificationId = verId;
      });
    };

    // This callback is called after the verification code has been sent by SMS to the provided phone number.
    final smsCodeSent = (String verId, [int forceCodeResend]) {
      setState(() {
        verificationId = verId;
        codeSent = true;
      });
    };

    // This callback will be invoked in two situations:
    // 1 - Instant verification. In some cases the phone number can be instantly
    //     verified without needing to send or enter a verification code.
    // 2 - Auto-retrieval. On some devices Google Play services can automatically
    //     detect the incoming verification SMS and perform verification without
    //     user action.

    final verifiedCompleted = (AuthCredential authResult) async {
      if (await authService.signIn(authResult, context)) {
        FirebaseUser currentUser = await authService.currentFirebaseUser;
        if (!await userDatabaseService.isPhoneExist(currentUser, context)) {
          userDatabaseService.insertNewUser(firebaseUser: currentUser, loginMode: LoginMode.loginWithPhone);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NormalUserDashboardPage(
                    user: currentUser,
                    loginMode: LoginMode.loginWithPhone,
                  )),
        );
      }
    };

    // This callback is invoked in an invalid request for verification is made,
    // for instance if the the phone number format is not valid.
    final verifiedFailed = (AuthException exception) {
      authService.notifyUser(exception.message, context);
    };

    // the verifyPhoneNumber method will not send a second SMS unless the original request has timed out.
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          // Phone number to verify
          timeout: const Duration(seconds: 5),
          // Timeout duration
          verificationCompleted: verifiedCompleted,
          verificationFailed: verifiedFailed,
          codeSent: smsCodeSent,
          codeAutoRetrievalTimeout: autoRetrieve);
      return true;
    } catch (error) {
      if (phoneNumber.isEmpty) {
        authService.notifyUser('The phone number could not be empty.', context);
      }
      return false;
    }
  }
}
