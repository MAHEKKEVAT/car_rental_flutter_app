import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('DefaultFirebaseOptions have not been configured for web - '
          'you can reconfigure this by running the FlutterFire CLI again.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for iOS - '
            'you can reconfigure this by running the FlutterFire CLI again.');
      case TargetPlatform.macOS:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for macOS - '
            'you can reconfigure this by running the FlutterFire CLI again.');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSezaTvNc7FqKxSDmBkWn8xFuTSSblLLQ',
    appId: '1:792017080827:android:44f7ea6ebe4f2f40c87b5e',
    messagingSenderId: '792017080827',
    projectId: 'geargo-e4cad',
    storageBucket: 'geargo-e4cad.firebasestorage.app',
  );
}