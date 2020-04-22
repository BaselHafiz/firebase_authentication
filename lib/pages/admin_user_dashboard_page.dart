import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseauthentication/pages/login_options_page.dart';
import 'package:firebaseauthentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/product_database_service.dart';
import 'add_and_update_product_page.dart';

// ignore: must_be_immutable
class AdminUserDashboardPage extends StatefulWidget {
  static const routeName = '/admin_user_dashboard_page';
  OperationMode operationMode = OperationMode.add;

  FirebaseUser user;

  AdminUserDashboardPage({this.user});

  @override
  _AdminUserDashboardPageState createState() => _AdminUserDashboardPageState();
}

class _AdminUserDashboardPageState extends State<AdminUserDashboardPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Authentication', style: TextStyle(color: Colors.deepPurple, fontSize: 18)),
        centerTitle: true,
      ),
      drawer: MainDrawer(user: widget.user, authService: authService),
      body: RefreshIndicator(
        onRefresh: () async {
          await getProducts(productService, context);
        },
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            createListViewOfProducts(products, productService, context),
            SizedBox(height: 15),
            Center(
              child: Text(
                widget.user.email,
                style: TextStyle(color: Colors.deepPurple, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Admin',
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
  Widget createListViewOfProducts(
      Stream<QuerySnapshot> products, ProductDatabaseService productService, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: products,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: UniqueKey(),
                secondaryBackground: Container(
                  color: Theme.of(context).errorColor,
                  child: Icon(Icons.update, color: Colors.white, size: 40),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                ),
                background: Container(
                  color: Theme.of(context).errorColor,
                  child: Icon(Icons.delete, color: Colors.white, size: 40),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(right: 20),
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                ),
                onDismissed: (DismissDirection direction) async {
                  if (direction == DismissDirection.endToStart) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddAndUpdateProductPage(
                                operationMode: OperationMode.update,
                                selectedDocument: snapshot.data.documents[index],
                              )),
                    );
                  }
                  if (direction == DismissDirection.startToEnd) {
                    if (await productService.deleteProductVer2(snapshot.data.documents[index], context)) {
                      /*if (snapshot.data.documents.contains(snapshot.data.documents[index])) {
                        setState(() {
                          snapshot.data.documents.removeAt(index);
                        });
                      }*/

                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Item is removed', style: TextStyle(fontSize: 16, color: Colors.amber)),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                // ignore: missing_return
                confirmDismiss: (DismissDirection direction) {
                  if (direction == DismissDirection.startToEnd) {
                    return showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        title: Text('Are you sure?'),
                        content: Text('Do you want to remove this item?',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (direction == DismissDirection.endToStart) {
                    return showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        title: Text('Are you sure?'),
                        content: Text('Do you want to update this item?',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Card(
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
            title: Text('Add Product', style: TextStyle(fontSize: 16)),
            leading: Icon(Icons.add_shopping_cart, color: Colors.cyan, size: 27),
            onTap: () {
              Navigator.pushNamed(context, AddAndUpdateProductPage.routeName);
            },
          ),
          ListTile(
            title: Text('Sign Out', style: TextStyle(fontSize: 16)),
            leading: Icon(Icons.exit_to_app, color: Colors.cyan, size: 27),
            onTap: () async {
              if (await DataConnectionChecker().hasConnection) {
                if (await authService.signOut(context)) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, LoginOptionsPage.routeName);
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
