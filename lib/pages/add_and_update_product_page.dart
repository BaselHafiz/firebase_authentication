import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/product_database_service.dart';
import 'admin_user_dashboard_page.dart';

enum OperationMode {
  add,
  update,
}

class AddAndUpdateProductPage extends StatefulWidget {
  static String routeName = '/add_and_update_product_page';
  OperationMode operationMode = OperationMode.add;
  DocumentSnapshot selectedDocument;

  AddAndUpdateProductPage({this.operationMode, this.selectedDocument});

  @override
  _AddAndUpdateProductPageState createState() => _AddAndUpdateProductPageState();
}

class _AddAndUpdateProductPageState extends State<AddAndUpdateProductPage> {
  String productName;
  String productColor;

  final productFormKey = GlobalKey<FormState>();
  ProductDatabaseService productDatabaseService;
  AuthService authService;

  @override
  Widget build(BuildContext context) {
    productDatabaseService = Provider.of<ProductDatabaseService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Firestore', style: TextStyle(color: Colors.deepPurple, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Form(
            key: productFormKey,
            child: Column(
              children: <Widget>[
                ...buildInputTextFields(),
                SizedBox(height: 20),
                buildSubmitButtons(),
                SizedBox(height: 10),
                Consumer<ProductDatabaseService>(
                  builder: (context, productService, _) => Visibility(
                    child: Center(child: CircularProgressIndicator()),
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    visible: productService.isLoading,
                  ),
                ),
              ],
            )),
      ),
    );
  }

  List<Widget> buildInputTextFields() {
    return [
      TextFormField(
        initialValue: widget.operationMode == OperationMode.update ? widget.selectedDocument.data['productName'] : null,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(labelText: 'Product Name'),
        validator: (value) => value.isEmpty ? 'Name is required' : null,
        onSaved: (value) {
          setState(() {
            productName = value;
          });
        },
      ),
      TextFormField(
        initialValue:
            widget.operationMode == OperationMode.update ? widget.selectedDocument.data['productColor'] : null,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(labelText: 'Product Color'),
        validator: (value) => value.isEmpty ? 'Color is required' : null,
        onSaved: (value) {
          setState(() {
            productColor = value;
          });
        },
      ),
    ];
  }

  Widget buildSubmitButtons() {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
      color: Colors.cyan,
      elevation: 7,
      child: widget.operationMode == OperationMode.add
          ? Text('Add Product', style: TextStyle(fontSize: 16, color: Colors.deepPurple))
          : Text('Update Product', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
      onPressed: validateAndSubmit,
    );
  }

  bool validateAndSave() {
    final form = productFormKey.currentState;
    if (!form.validate()) {
      return false;
    }
    form.save();
    return true;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      Map<String, String> newProduct = {
        'productId': DateTime.now().toIso8601String(),
        'productName': productName,
        'productColor': productColor,
      };

      if (await DataConnectionChecker().hasConnection) {
        widget.operationMode == OperationMode.add
            ? await productDatabaseService.addProduct(newProduct, context)
            : await productDatabaseService.updateProductVer2(widget.selectedDocument, newProduct, context);
        FirebaseUser currentUser = await authService.currentFirebaseUser;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminUserDashboardPage(user: currentUser)),
        );
      } else {
        productDatabaseService.notifyUser('No Internet connection.', context);
      }
    }
  }
}
