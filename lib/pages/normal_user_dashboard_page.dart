import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/pages/login_options_page.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/product_database_service.dart';

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
  Stream<QuerySnapshot> products;
  ProductDatabaseService productService;

  @override
  void didChangeDependencies() async {
    productService = Provider.of<ProductDatabaseService>(context, listen: false);
    await getProducts(productService, context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context, listen: false);
    final ProductDatabaseService productService = Provider.of<ProductDatabaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Authentication', style: TextStyle(color: Colors.deepPurple, fontSize: 18)),
        centerTitle: true,
      ),
      drawer: MainDrawer(user: widget.user, authService: authService, loginMode: widget.loginMode),
      body: RefreshIndicator(
        onRefresh: () async => await getProducts(productService, context),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            createListViewOfProducts(products),
            SizedBox(height: 15),
            Center(child: buildSignedInUserLabels(authService, widget.user)),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Normal User',
                style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
              ),
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
  Widget createListViewOfProducts(Stream<QuerySnapshot> products) {
    return StreamBuilder<QuerySnapshot>(
      stream: products,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: ListTile(
                  title: Text(
                    snapshot.data.documents[index].data['productName'],
                    style: TextStyle(color: Colors.deepPurple, fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    snapshot.data.documents[index].data['productColor'],
                    style: TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: CircleAvatar(
                    child: Image.asset('assets/login.png', height: 75, width: 75, fit: BoxFit.cover),
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // ignore: missing_return
  Widget buildSignedInUserLabels(AuthService authService, FirebaseUser user) {
    switch (widget.loginMode) {
      case LoginMode.loginWithPhone:
        return Text(
          user.phoneNumber,
          style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
        );

      case LoginMode.loginWithEmailAndPassword:
        return Text(
          user.email,
          style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
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
                style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          );
        } else if (user.email != null) {
          return Text(
            user.email,
            style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
          );
        } else {
          return Text(
            user.phoneNumber,
            style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
          );
        }
    }
  }

  Future<void> getProducts(ProductDatabaseService productService, BuildContext context) async {
    final retrievedProducts = await productService.retrieveProducts(context);
    if (retrievedProducts != null) {
      setState(() {
        products = retrievedProducts;
      });
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
            title: Text('Add Product', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
            leading: Icon(Icons.add_shopping_cart, color: Colors.cyan, size: 27),
            onTap: () {
              notifyUser('You should sign in as an Admin', context);
            },
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

  Future<Widget> notifyUser(String message, BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        title: Text('Error Occurred', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text('$message', style: TextStyle(fontSize: 18)),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
