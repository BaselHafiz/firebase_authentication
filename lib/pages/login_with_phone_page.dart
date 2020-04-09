/// Starts the phone number verification process for the given phone number.
///
/// Either sends an SMS with a 6 digit code to the phone number specified,
/// or sign's the user in and [verificationCompleted] is called.
///
/// No duplicated SMS will be sent out upon re-entry (before timeout).
///
/// Make sure to test all scenarios below:
///
///  * You directly get logged in if Google Play Services verified the phone
///     number instantly or helped you auto-retrieve the verification code.
///  * Auto-retrieve verification code timed out.
///  * Error cases when you receive [verificationFailed] callback.
///
/// [phoneNumber] The phone number for the account the user is signing up
///   for or signing into. Make sure to pass in a phone number with country
///   code prefixed with plus sign ('+').
///
/// [timeout] The maximum amount of time you are willing to wait for SMS
///   auto-retrieval to be completed by the library. Maximum allowed value
///   is 2 minutes. Use 0 to disable SMS-auto-retrieval. Setting this to 0
///   will also cause [codeAutoRetrievalTimeout] to be called immediately.
///   If you specified a positive value less than 30 seconds, library will
///   default to 30 seconds.
///
/// [forceResendingToken] The [forceResendingToken] obtained from [codeSent]
///   callback to force re-sending another verification SMS before the
///   auto-retrieval timeout.
///
/// [verificationCompleted] This callback must be implemented.
///   It will trigger when an SMS is auto-retrieved or the phone number has
///   been instantly verified. The callback will receive an [AuthCredential]
///   that can be passed to [signInWithCredential] or [linkWithCredential].
///
/// [verificationFailed] This callback must be implemented.
///   Triggered when an error occurred during phone number verification.
///
/// [codeSent] Optional callback.
///   It will trigger when an SMS has been sent to the users phone,
///   and will include a [verificationId] and [forceResendingToken].
///
/// [codeAutoRetrievalTimeout] Optional callback.
///   It will trigger when SMS auto-retrieval times out and provide a
///   [verificationId].

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/pages/login_options_page.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginWithPhonePage extends StatefulWidget {
  static String routeName = '/login_with_phone_page';

  @override
  _LoginWithPhonePageState createState() => _LoginWithPhonePageState();
}

class _LoginWithPhonePageState extends State<LoginWithPhonePage> {
  String phoneNo;
  String smsCode;
  bool codeSent = false;
  bool isVerifyButtonTapped = false;
  String verificationId;
  AuthService authService;

  @override
  Widget build(BuildContext context) {
    authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Firebase Authentication',
          style: TextStyle(
            color: Colors.deepPurple,
            fontSize: 18,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.deepPurple,
            ),
            iconSize: 25,
            onPressed: () => Navigator.of(context).pushReplacementNamed(LoginOptionsPage.routeName),
          ),
        ],
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
                child: isVerifyButtonTapped
                    ? Center(child: CircularProgressIndicator())
                    : Consumer<AuthService>(
                        builder: (context, auth, _) => auth.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : RaisedButton(
                                textColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                color: Colors.cyan,
                                elevation: 7,
                                child: codeSent
                                    ? Text(
                                        'Login',
                                        style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                                      )
                                    : Text(
                                        'Verify',
                                        style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                                      ),
                                onPressed: () async {
                                  codeSent
                                      ? authService.signInWithOTP(smsCode, verificationId)
                                      : await verifyPhone(phoneNo);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyPhone(String phoneNumber) async {
    setState(() {
      isVerifyButtonTapped = true;
    });

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
      await authService.signIn(authResult);
    };

    // This callback is invoked in an invalid request for verification is made,
    // for instance if the the phone number format is not valid.
    final verifiedFailed = (AuthException exception) {
      print(exception.message);
    };

    // the verifyPhoneNumber method will not send a second SMS unless the original request has timed out.
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber, // Phone number to verify
        timeout: const Duration(seconds: 5), // Timeout duration
        verificationCompleted: verifiedCompleted,
        verificationFailed: verifiedFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve);

    await Future.delayed(Duration(milliseconds: 500)).then((_) async {
      setState(() {
        isVerifyButtonTapped = false;
      });
    });
  }
}
