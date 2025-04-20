import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseConfig {
  static Future<bool> initializeFirebase() async {
    try {
      // Initialize Firebase with the provided options
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyDSezaTvNc7FqKxSDmBkWn8xFuTSSblLLQ", // Your actual API key
          appId: "1:792017080827:android:98cac1ab33b0726dc87b5e", // Your Mobile SDK app ID
          messagingSenderId: "792017080827", // Your project number
          projectId: "geargo-e4cad", // Your project ID
          storageBucket: "geargo-e4cad.appspot.com", // Your storage bucket
        ),
      );
      // Show a toast message
      Fluttertoast.showToast(
        msg: "☑️Firebase Initialized Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return true; // Return true if initialization is successful
    } catch (e) {
      // Handle initialization error
      Fluttertoast.showToast(
        msg: "❌ Firebase Initialization Failed: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false; // Return false if there's an error
    }
  }
}