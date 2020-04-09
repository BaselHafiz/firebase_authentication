import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/login_options_page.dart';
import 'pages/dashboard_page.dart';
import 'services/auth_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthService(),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Firebase Authentication',
          theme: ThemeData(
            primarySwatch: Colors.cyan,
          ),
          home: authService.handleAuth(),
          routes: {
            LoginOptionsPage.routeName: (context) => LoginOptionsPage(),
            DashboardPage.routeName: (context) => DashboardPage(),
          },
        ),
      ),
    );
  }
}
