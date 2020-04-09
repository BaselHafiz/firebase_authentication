import 'package:firebaseauthentication/pages/login_options_page.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  String _passwordConfirmed;
  final formKey = GlobalKey<FormState>();
  FormType formType = FormType.login;
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  ...buildInputTextFields(),
                  SizedBox(height: 20),
                  ...buildSubmitButtons(),
                  SizedBox(height: 10),
                  Consumer<AuthService>(
                    builder: (context, auth, _) =>
                        auth.isLoading ? Center(child: CircularProgressIndicator()) : Container(),
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
        ),
        TextFormField(
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password confirm is required';
            } else if (_passwordConfirmed != _password) {
              return 'Password do not match';
            } else
              return null;
          },
          obscureText: true,
          onSaved: (value) => _passwordConfirmed = value,
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
              formKey.currentState.reset();
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
              formKey.currentState.reset();
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
    final form = formKey.currentState;
    if (!form.validate()) {
      return false;
    }
    form.save();
    return true;
  }

  void validateAndSubmit() {
    if (validateAndSave()) {
      if (formType == FormType.login) {
        authService.signInWithEmailAndPassword(_email, _password);
      } else {
        authService.createUserWithEmailAndPassword(_email, _password);
      }
    }
  }
}
