import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:firebaseauthentication/services/user_database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'normal_user_dashboard_page.dart';

enum FormType {
  login,
  register,
}

class LoginWithEmailAndPasswordPage extends StatefulWidget {
  static String routeName = '/login_with_email_and_password_page';

  @override
  _LoginWithEmailAndPasswordPageState createState() => _LoginWithEmailAndPasswordPageState();
}

class _LoginWithEmailAndPasswordPageState extends State<LoginWithEmailAndPasswordPage> {
  String _email;
  String _password;
  final TextEditingController _passwordTextController = TextEditingController();
  final allUsersFormKey = GlobalKey<FormState>();
  FormType formType = FormType.login;
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
              key: allUsersFormKey,
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
    if (formType == FormType.login) {
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
    } else {
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
          controller: _passwordTextController,
          obscureText: true,
        ),
        TextFormField(
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password confirm is required';
            } else if (_passwordTextController.text != value) {
              return 'Password do not match';
            } else
              return null;
          },
          obscureText: true,
          decoration: InputDecoration(labelText: 'Confirm Password'),
        ),
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (formType == FormType.login) {
      return [
        RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
          color: Colors.cyan,
          elevation: 7,
          child: Text('Login', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
            onPressed: () {
              allUsersFormKey.currentState.reset();
              setState(() {
                formType = FormType.register;
              });
            },
            child: Text(
              'Create an account',
              style: TextStyle(color: Colors.deepPurple, fontSize: 16),
            )),
      ];
    } else {
      return [
        RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
          color: Colors.cyan,
          elevation: 7,
          child: Text('Create an account', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
          onPressed: validateAndSubmit,
        ),
        FlatButton(
            onPressed: () {
              allUsersFormKey.currentState.reset();
              setState(() {
                formType = FormType.login;
              });
            },
            child: Text(
              'Have an account? login',
              style: TextStyle(fontSize: 16, color: Colors.deepPurple),
            )),
      ];
    }
  }

  bool validateAndSave() {
    final form = allUsersFormKey.currentState;
    if (!form.validate()) {
      return false;
    }
    form.save();
    return true;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (formType == FormType.login) {
        if (await DataConnectionChecker().hasConnection) {
          if (await authService.signInWithEmailAndPassword(_email, _password, context)) {
            FirebaseUser currentUser = await authService.currentFirebaseUser;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => NormalUserDashboardPage(
                        user: currentUser,
                        loginMode: LoginMode.loginWithEmailAndPassword,
                      )),
            );
          }
        } else {
          authService.notifyUser('No Internet connection.', context);
        }
      } else {
        if (await DataConnectionChecker().hasConnection) {
          if (await authService.createUserWithEmailAndPassword(_email, _password, context)) {
            FirebaseUser currentUser = await authService.currentFirebaseUser;

            if (!await userDatabaseService.isEmailExist(currentUser, context)) {
              userDatabaseService.insertNewUser(
                  firebaseUser: currentUser, loginMode: LoginMode.loginWithEmailAndPassword);
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => NormalUserDashboardPage(
                        user: currentUser,
                        loginMode: LoginMode.loginWithEmailAndPassword,
                      )),
            );
          }
        } else {
          authService.notifyUser('No Internet connection.', context);
        }
      }
    }
  }
}
