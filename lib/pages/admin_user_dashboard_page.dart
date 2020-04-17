import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

// ignore: must_be_immutable
class AdminUserDashboardPage extends StatefulWidget {
  static const routeName = '/admin_user_dashboard_page';

  FirebaseUser user;

  AdminUserDashboardPage({this.user});

  @override
  _AdminUserDashboardPageState createState() => _AdminUserDashboardPageState();
}

class _AdminUserDashboardPageState extends State<AdminUserDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Authentication', style: TextStyle(color: Colors.deepPurple, fontSize: 18)),
        centerTitle: true,
      ),
      drawer: MainDrawer(user: widget.user, authService: authService),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.user.email,
                style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
              color: Colors.cyan,
              elevation: 7,
              child: Text('LogOut', style: TextStyle(color: Colors.deepPurple, fontSize: 15)),
              onPressed: () async {
                if (await DataConnectionChecker().hasConnection) {
                  if (await authService.signOut(context)) {
                    Navigator.pop(context);
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
            SizedBox(height: 10),
            Text('Admins Page', style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class MainDrawer extends StatelessWidget {
  FirebaseUser user;
  AuthService authService;

  MainDrawer({this.user, this.authService});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 8,
      child: ListView(
        children: <Widget>[
          // header
          UserAccountsDrawerHeader(
            accountEmail: Text(user.email, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  Navigator.pop(context);
                  Navigator.pop(context);
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
