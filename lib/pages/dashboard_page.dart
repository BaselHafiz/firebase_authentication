import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

// ignore: must_be_immutable
class DashboardPage extends StatelessWidget {
  static const routeName = '/dashboard_page';

  String userEmail;
  String userUid;
  String userGoogleEmail;
  String userGoogleProfilePhotoUrl;
  String userFacebookEmail;
  String userFacebookProfilePhotoUrl;

  DashboardPage({
    this.userUid,
    this.userEmail,
    this.userGoogleEmail,
    this.userGoogleProfilePhotoUrl,
    this.userFacebookEmail,
    this.userFacebookProfilePhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Consumer<AuthService>(
          builder: (context, auth, _) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildSignedInUserLabels(),
              SizedBox(height: 15),
              auth.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                      ),
                      color: Colors.cyan,
                      elevation: 7,
                      child: Text(
                        'LogOut',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () async {
                        auth.loginMode = LoginMode.noLoginOptionChosen;
                        await auth.signOut();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: missing_return
  Widget buildSignedInUserLabels() {
    if (userFacebookEmail != null && userFacebookProfilePhotoUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(userFacebookProfilePhotoUrl)),
          SizedBox(height: 15),
          Text(userFacebookEmail,
              style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
    }

    if (userGoogleEmail != null && userGoogleProfilePhotoUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(userGoogleProfilePhotoUrl)),
          SizedBox(height: 15),
          Text(userGoogleEmail, style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
    } else if (userEmail != null) {
      return Text(userEmail, style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold));
    } else if (userUid != null) {
      return Text(userUid, style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold));
    } else
      return Container();
  }
}
