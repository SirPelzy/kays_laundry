import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart'; // We'll create this

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kay\'s Laundry',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Or your preferred theme color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // TODO: Add more theme customizations (fonts, button styles, etc.)
      ),
      // For now, we start directly at the login screen
      // Later, we'll add logic here to check if the user is already logged in
      home: const LoginScreen(),
      // TODO: Setup routing for navigation between screens
    );
  }
}