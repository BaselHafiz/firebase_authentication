import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/pages/admin_user_dashboard_page.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:firebaseauthentication/services/user_database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class LoginWithEmailAndPasswordAdminsPage extends StatefulWidget {
  static String routeName = '/login_with_email_and_password_admins_page';

  @override
  _LoginWithEmailAndPasswordAdminsPageState createState() => _LoginWithEmailAndPasswordAdminsPageState();
}

class _LoginWithEmailAndPasswordAdminsPageState extends State<LoginWithEmailAndPasswordAdminsPage> {
  String _email;
  String _password;

  final adminsFormKey = GlobalKey<FormState>();

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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Form(
              key: adminsFormKey,
              child: Column(
                children: <Widget>[
                  ...buildInputTextFields(),
                  SizedBox(height: 20),
                  ...buildSubmitButtons(),
                  SizedBox(height: 10),
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
              )),
        ),
      ),
    );
  }

  List<Widget> buildInputTextFields() {
    return [
      TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value.isEmpty) {
            return 'Email is required';
          } else if (!RegExp(r'^\w+[\w-\.]*\@\w+((-\w+)|(\w*))\.[a-z]{2,3}$').hasMatch(value)) {
            return 'Email isn\'t correct';
          }
          return null;
        },
        onSaved: (value) => _email = value,
      ),
      TextFormField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(labelText: 'Password'),
        validator: (value) {
          if (value.isEmpty) {
            return 'Password is required';
          } else if (value.length < 6) {
            return 'Password should be 6+ characters';
          }
          return null;
        },
        onSaved: (value) => _password = value,
        obscureText: true,
      )
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
        color: Colors.cyan,
        elevation: 7,
        child: Text('Login as an Admin', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
        onPressed: validateAndSubmit,
      ),
    ];
  }

  bool validateAndSave() {
    final form = adminsFormKey.currentState;
    if (!form.validate()) {
      return false;
    }
    form.save();
    return true;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (await DataConnectionChecker().hasConnection) {
        if (await authService.signInWithEmailAndPassword(_email, _password, context)) {
          FirebaseUser currentUser = await authService.currentFirebaseUser;
          if (await userDatabaseService.isAdmin(currentUser, context)) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminUserDashboardPage(user: currentUser)),
            );
          } else {
            authService.signOut(context);
          }
        }
      } else {
        authService.notifyUser('No Internet connection.', context);
      }
    }
  }
}
