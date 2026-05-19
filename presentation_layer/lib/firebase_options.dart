import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: 'dummy-app-id',
    messagingSenderId: 'dummy-sender-id',
    projectId: 'dummy-project-id',
    authDomain: 'dummy-auth-domain.firebaseapp.com',
    storageBucket: 'dummy-storage-bucket.appspot.com',
    databaseURL: 'dummy-database-url.firebaseio.com',
  );
}
