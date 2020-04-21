import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/pages/add_and_update_product_page.dart';
import 'package:firebaseauthentication/pages/admin_user_dashboard_page.dart';
import 'package:firebaseauthentication/pages/normal_user_dashboard_page.dart';
import 'package:firebaseauthentication/services/product_database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/login_options_page.dart';
import 'pages/login_with_email_and_password_admins_page.dart';
import 'pages/login_with_email_and_password_page.dart';
import 'pages/login_with_phone_page.dart';
import 'services/auth_service.dart';
import 'services/user_database_service.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => AuthService(),
        child: MyApp(),
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseUser currentSignedInUser;
  bool isAuthenticated = false;

  @override
  void didChangeDependencies() async {
    AuthService authService = Provider.of<AuthService>(context, listen: false);

    authService.autoAuthenticate();
    authService.userSubject.listen((bool value) {
      setState(() {
        isAuthenticated = value;
      });
    });

    currentSignedInUser = await authService.currentFirebaseUser;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => UserDatabaseService()),
        ChangeNotifierProvider(create: (context) => ProductDatabaseService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firebase Authentication',
        theme: ThemeData(primarySwatch: Colors.cyan),
        home: isAuthenticated ? NormalUserDashboardPage(user: currentSignedInUser) : LoginOptionsPage(),
        routes: <String, WidgetBuilder>{
          LoginOptionsPage.routeName: (context) => LoginOptionsPage(),
          LoginWithPhonePage.routeName: (context) => LoginWithPhonePage(),
          LoginWithEmailAndPasswordPage.routeName: (context) => LoginWithEmailAndPasswordPage(),
          LoginWithEmailAndPasswordAdminsPage.routeName: (context) => LoginWithEmailAndPasswordAdminsPage(),
          NormalUserDashboardPage.routeName: (context) => NormalUserDashboardPage(),
          AdminUserDashboardPage.routeName: (context) => AdminUserDashboardPage(),
          AddAndUpdateProductPage.routeName: (context) => AddAndUpdateProductPage(operationMode: OperationMode.add),
        },
      ),
    );
  }
}
