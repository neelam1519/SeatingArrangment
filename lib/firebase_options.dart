// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCKWX7s5PLXJBZzc-Tc-zVYt7iWezrEXIg',
    appId: '1:390220804592:android:be9c2f16df8226b7786d35',
    messagingSenderId: '390220804592',
    projectId: 'adroit-chemist-368310',
    databaseURL: 'https://adroit-chemist-368310-default-rtdb.firebaseio.com',
    storageBucket: 'adroit-chemist-368310.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAGw-jc9Pl-qyAvuIm-9LjH6_jXBf88tTI',
    appId: '1:390220804592:ios:9eeb8985423dc415786d35',
    messagingSenderId: '390220804592',
    projectId: 'adroit-chemist-368310',
    databaseURL: 'https://adroit-chemist-368310-default-rtdb.firebaseio.com',
    storageBucket: 'adroit-chemist-368310.appspot.com',
    androidClientId: '390220804592-0jlknm18dqoc3f6debiogmfdeo01bscv.apps.googleusercontent.com',
    iosClientId: '390220804592-s5o44m4amm06ar5pn11kpelv44k6vo98.apps.googleusercontent.com',
    iosBundleId: 'com.neelam.findAnyFlutter',
  );
}
