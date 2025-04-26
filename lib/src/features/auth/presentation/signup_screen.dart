// lib/src/features/auth/presentation/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorMessage; // To display Firebase errors

  Future<void> _createAccount() async {
    print("--- _createAccount: Started ---"); // <-- DEBUG
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Reset error message at the start of attempt
    setState(() {
       _errorMessage = null;
    });

    if (!_agreeToTerms) {
      print("--- _createAccount: Terms not agreed ---"); // <-- DEBUG
      setState(() {
         _errorMessage = 'Please agree to the Terms and Conditions';
      });
      return; // Stop execution
    }
    print("--- _createAccount: Terms agreed ---"); // <-- DEBUG


    if (_formKey.currentState!.validate()) {
       print("--- _createAccount: Form is valid ---"); // <-- DEBUG
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Clear previous errors again just in case
      });
      print("--- _createAccount: Set loading to true ---"); // <-- DEBUG

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        print('--- _createAccount: Attempting Firebase signup for: $email ---'); // <-- DEBUG

        // --- Firebase Sign Up Logic ---
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // If the above line completes without error, this line will execute
        print('--- _createAccount: Firebase Signup Success! User UID ${credential.user?.uid} ---'); // <-- DEBUG

        // Optionally update the user's profile (name, phone)
        if (credential.user != null) {
           print('--- _createAccount: Updating profile (placeholder) for ${credential.user!.uid}... ---'); // <-- DEBUG
           // await credential.user!.updateDisplayName(_nameController.text.trim());
        }
        // --- End Firebase Sign Up Logic ---

        // We DON'T set isLoading = false here on success. Auth listener handles navigation.
        print("--- _createAccount: Success block finished ---"); // <-- DEBUG

      } on FirebaseAuthException catch (e) {
        print('--- _createAccount: Caught FirebaseAuthException: ${e.code} - ${e.message} ---'); // <-- DEBUG
        if (e.code == 'weak-password') {
          _errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'An account already exists for that email.';
        } else if (e.code == 'invalid-email') {
           _errorMessage = 'The email address is badly formatted.';
        } else {
          _errorMessage = 'An error occurred during sign up: ${e.message}'; // Show more details
        }
         // Stop loading ONLY on error
         if (mounted) { // Check if widget is still mounted
           setState(() {
             _isLoading = false;
           });
         }
         print("--- _createAccount: Set loading to false due to FirebaseAuthException ---"); // <-- DEBUG
      } catch (e, stackTrace) { // Catch generic errors too
         print('--- _createAccount: Caught Generic Exception: $e ---'); // <-- DEBUG
         print('--- Stack Trace: $stackTrace ---'); // <-- DEBUG Print stack trace
         _errorMessage = 'An unexpected error occurred. Please try again.';
          // Stop loading ONLY on error
         if (mounted) { // Check if widget is still mounted
            setState(() {
              _isLoading = false;
            });
         }
          print("--- _createAccount: Set loading to false due to Generic Exception ---"); // <-- DEBUG
      }
    } else {
       print("--- _createAccount: Form is invalid ---"); // <-- DEBUG
       // If form validation fails (passwords don't match etc.)
       if (mounted) {
         setState(() {
            _errorMessage = 'Please fix the errors in the form.';
         });
       }
    }
     print("--- _createAccount: Finished ---"); // <-- DEBUG
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     print("--- SignUpScreen build method --- isLoading: $_isLoading"); // <-- DEBUG
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
        title: const Text(
          'Kay\'s Laundry',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(), // Disable during loading
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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

                // Full Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
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

                // Phone Number Field (Keep for now, even if not used for auth directly)
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Basic validation example
                    if (value.length < 10) {
                       return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: 'Min. 6 characters', // Firebase default minimum
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    // Firebase enforces minimum 6 chars by default
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),

                // Terms and Conditions Checkbox
                CheckboxListTile(
                  title: RichText(
                     text: TextSpan(
                       text: 'I agree to the ',
                       style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
                       children: <TextSpan>[
                         TextSpan(
                           text: 'Terms and Conditions',
                           style: const TextStyle(
                             color: Colors.blue,
                             decoration: TextDecoration.underline,
                           ),
                           // TODO: Add recognizer for Terms link tap
                         ),
                       ],
                     ),
                   ),
                  value: _agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                      if (_agreeToTerms && _errorMessage == 'Please agree to the Terms and Conditions') {
                         _errorMessage = null; // Clear terms error if checked
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24.0),

                // Create Account Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Create Account', style: TextStyle(fontSize: 16)),
                      ),
                const SizedBox(height: 16.0),

                // Back to Login Link
                TextButton(
                  onPressed: _isLoading ? null : () { // Disable during loading
                    Navigator.of(context).pop();
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
