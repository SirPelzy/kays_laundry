// lib/src/features/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage; // To display Firebase errors

  Future<void> _login() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Clear previous errors
      });

      try {
        print('Attempting Firebase login with Email: ${_emailController.text}');
        // --- Firebase Login Logic ---
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(), // Use trim()
          password: _passwordController.text,
        );
        print('Firebase Login Success: User UID ${credential.user?.uid}');
        // --- End Firebase Login Logic ---

        // No need to set isLoading false here, auth state listener will handle navigation

      } on FirebaseAuthException catch (e) {
        print('Firebase Login Error: ${e.code}');
        // Handle specific Firebase errors
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          _errorMessage = 'Incorrect email or password.';
        } else if (e.code == 'wrong-password') { // Might be covered by invalid-credential now
          _errorMessage = 'Incorrect password.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'The email address is badly formatted.';
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
        setState(() {
          _isLoading = false; // Stop loading on error
        });
      } catch (e) {
        // Handle other potential errors
        print('Login Error: $e');
         _errorMessage = 'An unexpected error occurred.';
         setState(() {
          _isLoading = false; // Stop loading on error
        });
      }
      // Note: We don't manually navigate here. The auth state listener in app.dart will do it.
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login - Kay\'s Laundry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // Error Message Display
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email', // Changed label to Email only
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  // Firebase handles password complexity, but basic length check is okay
                  // if (value.length < 6) {
                  //   return 'Password must be at least 6 characters';
                  // }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement Forgot Password navigation/logic (Firebase has password reset)
                    print('Forgot Password button pressed');
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Forgot Password Not Implemented Yet')),
                     );
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('Login'),
                    ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: _isLoading ? null : () { // Disable during loading
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
