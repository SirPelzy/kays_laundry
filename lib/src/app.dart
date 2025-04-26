// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Re-enable Firebase Auth import
import 'features/main_scaffold.dart';
import 'features/auth/presentation/login_screen.dart'; // Re-enable LoginScreen import

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kay\'s Laundry',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      // Use StreamBuilder to listen to auth state changes
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Listen to the stream
        builder: (context, snapshot) {
          // Added print statement to see stream builder activity
          print("--- StreamBuilder Rebuilding --- ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, HasError: ${snapshot.hasError}");

          // Show loading indicator while checking auth state initially
          if (snapshot.connectionState == ConnectionState.waiting) {
             print("StreamBuilder: State is waiting..."); // Added print
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Check for errors in the stream
          if (snapshot.hasError) {
             print("StreamBuilder: Error in auth stream: ${snapshot.error}"); // Added print
             // Optionally show an error screen or fallback to login
             return const Scaffold(
                body: Center(child: Text('Error verifying authentication.')),
             );
          }


          // If user is logged in (snapshot has data and data is not null)
          // Check explicitly for non-null data along with hasData
          if (snapshot.hasData && snapshot.data != null) {
             print("StreamBuilder: User is logged in (${snapshot.data!.uid}). Showing MainScaffold."); // Added print
             return const MainScaffold(); // Show the main app screen
          }

          // If user is not logged in (snapshot has no data or data is null)
          print("StreamBuilder: User is logged out. Showing LoginScreen."); // Added print
          return const LoginScreen(); // Show the login screen
        },
      ),
    );
  }
}
