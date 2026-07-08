// File generated from google-services.json for project evergo-1d57e
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios – '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Values sourced directly from assets/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAS-qnD3QZbOerQcDnAmPXYRr-rbvhpPiI',
    appId: '1:1049910293836:android:44c53109de788f92080be9',
    messagingSenderId: '1049910293836',
    projectId: 'evergo-1d57e',
    storageBucket: 'evergo-1d57e.firebasestorage.app',
  );

  // Web placeholder (not used unless targeting web)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAS-qnD3QZbOerQcDnAmPXYRr-rbvhpPiI',
    appId: '1:1049910293836:web:placeholder',
    messagingSenderId: '1049910293836',
    projectId: 'evergo-1d57e',
    storageBucket: 'evergo-1d57e.firebasestorage.app',
    authDomain: 'evergo-1d57e.firebaseapp.com',
  );
}
