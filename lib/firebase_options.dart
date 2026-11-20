import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS FirebaseOptions not configured yet.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not supported for this platform.',
        );
    }
  }

  // ── Android (from google-services.json) ───────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFN-AVBylQTGSSM5Cx_iS-jLc7BC3AEPw',
    appId: '1:970966249206:android:3ee791d8a7e071db55c6d7',
    messagingSenderId: '970966249206',
    projectId: 'my-testankush',
    storageBucket: 'my-testankush.firebasestorage.app',
  );

  // ── Web (add your web API key from Firebase Console → Project Settings) ───
  // Go to: https://console.firebase.google.com/project/my-testankush/settings/general
  // Add a Web app if you haven't, then copy the config values below.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAFN-AVBylQTGSSM5Cx_iS-jLc7BC3AEPw',
    appId: '1:970966249206:web:REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '970966249206',
    projectId: 'my-testankush',
    storageBucket: 'my-testankush.firebasestorage.app',
    authDomain: 'my-testankush.firebaseapp.com',
  );
}
