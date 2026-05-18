// ⚠️ هذا الملف يُنشأ تلقائياً عبر FlutterFire CLI
// لا تعدّل هذا الملف يدوياً
//
// خطوات إنشائه:
//   1. npm install -g firebase-tools
//   2. dart pub global activate flutterfire_cli
//   3. firebase login
//   4. flutterfire configure
//
// سيُستبدل هذا الملف بالإعدادات الحقيقية بعد تشغيل الأمر أعلاه

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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── استبدل هذه القيم بالقيم الحقيقية من console.firebase.google.com ──
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    authDomain: 'REPLACE_WITH_PROJECT_ID.firebaseapp.com',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBni4zErXrTvV4o1kpnowJ5veHmxrNDWdI',
    appId: '1:714187758974:android:9e2f75be88eb6469ea672f',
    messagingSenderId: '714187758974',
    projectId: 'boosla-app-e68c2',
    storageBucket: 'boosla-app-e68c2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDGLqBYeFawxyoknmWRii6J7KcKNZl4_qY',
    appId: '1:714187758974:ios:358ede8d05bca16cea672f',
    messagingSenderId: '714187758974',
    projectId: 'boosla-app-e68c2',
    storageBucket: 'boosla-app-e68c2.firebasestorage.app',
    iosBundleId: 'com.example.booslaApp',
  );
}
