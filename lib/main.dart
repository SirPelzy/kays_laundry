// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'src/app.dart';

// --- ADD YOUR FIREBASE CONFIG VALUES DIRECTLY BELOW ---
const String _apiKey = "AIzaSyAAczh--stQRFdaV97bNkJsVn-e6pLPQUs";
const String _authDomain = "kay-s-laundry.firebaseapp.com";
const String _projectId = "kay-s-laundry";
const String _storageBucket = "kay-s-laundry.firebasestorage.app";
const String _messagingSenderId = "99689271732";
const String _appId = "1:99689271732:web:127999ed1eb923b05a22e1";
const String _measurementId = "G-ZK0DBXWPCE"; 

// --- END FIREBASE CONFIG VALUES ---


Future<void> main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are ready

  // Initialize Firebase using direct values
  try {
     print("Initializing Firebase...");
     await Firebase.initializeApp(
       options: const FirebaseOptions(
         // Pass the values directly as named arguments
         apiKey: _apiKey,
         authDomain: _authDomain,
         projectId: _projectId,
         storageBucket: _storageBucket,
         messagingSenderId: _messagingSenderId,
         appId: _appId,
         // measurementId: _measurementId, // Optional
       ),
     );
     print("Firebase initialized successfully!");
  } catch (e) {
     print("Error initializing Firebase: $e");
     // Handle initialization error (e.g., show an error message or exit)
  }

  runApp(const MyApp());
}
