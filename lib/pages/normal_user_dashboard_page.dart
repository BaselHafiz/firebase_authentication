import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/pages/login_options_page.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

enum LoginMode {
  loginWithPhone,
  loginWithEmailAndPassword,
  loginWithGoogle,
  loginWithFacebook,
}

// ignore: must_be_immutable
class NormalUserDashboardPage extends StatefulWidget {
  static const routeName = '/normal_user_dashboard_page';

  FirebaseUser user;
  LoginMode loginMode;

  NormalUserDashboardPage({this.user, this.loginMode});

  @override
  _NormalUserDashboardPageState createState() => _NormalUserDashboardPageState();
}

class _NormalUserDashboardPageState extends State<NormalUserDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Authentication', style: TextStyle(color: Colors.deepPurple, fontSize: 18)),
        centerTitle: true,
      ),
      drawer: MainDrawer(user: widget.user, authService: authService, loginMode: widget.loginMode),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildSignedInUserLabels(authService, widget.user),
            SizedBox(height: 15),
            RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
              color: Colors.cyan,
              elevation: 7,
              child: Text('LogOut', style: TextStyle(color: Colors.deepPurple, fontSize: 15)),
              onPressed: () async {
                if (await DataConnectionChecker().hasConnection) {
                  if (await authService.signOut(context)) {
                    if (widget.loginMode == LoginMode.loginWithPhone ||
                        widget.loginMode == LoginMode.loginWithEmailAndPassword) {
                      Navigator.pop(context);
                    } else if (widget.loginMode == LoginMode.loginWithGoogle ||
                        widget.loginMode == LoginMode.loginWithFacebook) {
                      Navigator.pushReplacementNamed(context, LoginOptionsPage.routeName);
                    } else {
                      Navigator.pushReplacementNamed(context, LoginOptionsPage.routeName);
                    }
                  }
                } else {
                  authService.notifyUser('No Internet connection.', context);
                }
              },
            ),
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
    );
  }

  // ignore: missing_return
  Widget buildSignedInUserLabels(AuthService authService, FirebaseUser user) {
    switch (widget.loginMode) {
      case LoginMode.loginWithPhone:
        return Text(
          user.phoneNumber,
          style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
        );

      case LoginMode.loginWithEmailAndPassword:
        return Text(
          user.email,
          style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
        );

      case LoginMode.loginWithGoogle:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.photoUrl)),
            SizedBox(height: 15),
            Text(
              user.email,
              style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        );

      case LoginMode.loginWithFacebook:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.photoUrl)),
            SizedBox(height: 15),
            Text(
              user.email,
              style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        );

      default:
        if (user.photoUrl != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.photoUrl)),
              SizedBox(height: 15),
              Text(
                user.email,
                style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          );
        } else if (user.email != null) {
          return Text(
            user.email,
            style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
          );
        } else {
          return Text(
            user.phoneNumber,
            style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
          );
        }
    }
  }
}

class MainDrawer extends StatelessWidget {
  FirebaseUser user;
  AuthService authService;
  LoginMode loginMode;

  MainDrawer({this.user, this.authService, this.loginMode});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 8,
      child: ListView(
        children: <Widget>[
          // header
          user.photoUrl != null
              ? UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.cyan.shade200),
                  accountName: Text(user.displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  accountEmail: Text(user.email, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  currentAccountPicture:
                      GestureDetector(child: CircleAvatar(maxRadius: 50, backgroundImage: NetworkImage(user.photoUrl))),
                )
              : user.email != null
                  ? UserAccountsDrawerHeader(
                      accountEmail: Text(user.email, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    )
                  : UserAccountsDrawerHeader(
                      accountName: Text(user.phoneNumber, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
          // body
          ListTile(
            title: Text('Home Page', style: TextStyle(fontSize: 16)),
            leading: Icon(Icons.home, color: Colors.cyan, size: 27),
            onTap: () {},
          ),
          ListTile(
            title: Text('My Account', style: TextStyle(fontSize: 16)),
            leading: Icon(Icons.person, color: Colors.cyan, size: 27),
            onTap: () {},
          ),
          ListTile(
            title: Text('My Orders', style: TextStyle(fontSize: 16)),
            leading: Icon(Icons.shopping_basket, color: Colors.cyan, size: 27),
            onTap: () {},
          ),
          ListTile(
            title: Text('Sign Out', style: TextStyle(fontSize: 16)),
            leading: Icon(Icons.exit_to_app, color: Colors.cyan, size: 27),
            onTap: () async {
              if (await DataConnectionChecker().hasConnection) {
                if (await authService.signOut(context)) {
                  if (loginMode == LoginMode.loginWithPhone || loginMode == LoginMode.loginWithEmailAndPassword) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else if (loginMode == LoginMode.loginWithGoogle || loginMode == LoginMode.loginWithFacebook) {
                    Navigator.pushReplacementNamed(context, LoginOptionsPage.routeName);
                  } else {
                    Navigator.pushReplacementNamed(context, LoginOptionsPage.routeName);
                  }
                }
              } else {
                authService.notifyUser('No Internet connection.', context);
              }
            },
          ),
          Divider(color: Colors.deepPurple),
          ListTile(
            title: Text('Settings', style: TextStyle(fontSize: 16)),
            leading: Icon(Icons.settings, color: Colors.cyan, size: 27),
            onTap: () {},
          ),
          ListTile(
            title: Text('About', style: TextStyle(fontSize: 16)),
            leading: Icon(Icons.help, color: Colors.cyan, size: 27),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
