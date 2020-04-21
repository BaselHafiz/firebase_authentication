import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductDatabaseService with ChangeNotifier {
  bool isLoading = false;

  Future<bool> addProduct(Map<String, dynamic> productData, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      await Firestore.instance.collection('products').add(productData);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      notifyUser(error.message.toString(), context);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProductVer1(
      DocumentSnapshot selectedDocument, Map<String, dynamic> newData, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      await Firestore.instance.collection('products').document(selectedDocument.documentID).updateData(newData);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      notifyUser(error.message.toString(), context);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProductVer1(DocumentSnapshot selectedDocument, BuildContext context) async {
    try {
      await Firestore.instance.collection('products').document(selectedDocument.documentID).delete();
      return true;
    } catch (error) {
      notifyUser(error.message.toString(), context);
      return false;
    }
  }

  Future<bool> updateProductVer2(
      DocumentSnapshot selectedDocument, Map<String, dynamic> newData, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      // todo

      isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      notifyUser(error.message.toString(), context);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProductVer2(DocumentSnapshot selectedDocument, BuildContext context) async {
    try {
      // todo

      return true;
    } catch (error) {
      notifyUser(error.message.toString(), context);
      return false;
    }
  }

  // ignore: missing_return
  Future<QuerySnapshot> retrieveProducts(BuildContext context) async {
    try {
      QuerySnapshot snapshots = await Firestore.instance.collection('products').getDocuments();
      if (snapshots.documents.isNotEmpty) {
        return snapshots;
      }
    } catch (error) {
      notifyUser(error.message.toString(), context);
    }
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
