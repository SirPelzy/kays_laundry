import 'package:flutter/material.dart';

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

  Future<void> _createAccount() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_agreeToTerms) {
      // TODO: Show snackbar or dialog informing user they must agree to terms
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Conditions')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // --- TODO: Implement Sign Up Logic ---
      // 1. Get data: _nameController.text, _emailController.text, etc.
      // 2. Call your authentication service (Firebase Auth or backend API)
      print('Attempting sign up for: ${_emailController.text}');
      // Simulate network call
      await Future.delayed(const Duration(seconds: 2));
      // --- End Sign Up Logic ---

      setState(() {
        _isLoading = false;
      });
      // TODO: Navigate to home screen on success
      // TODO: Show error message on failure (e.g., email already exists)
    }
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
    return Scaffold(
      // Using AppBar for easy back arrow and title structure
      appBar: AppBar(
        // Light gray header background as requested
        backgroundColor: Colors.grey[100],
        elevation: 0, // Remove shadow
        // Using title spacing and centerTitle for logo placeholder
        titleSpacing: 0,
        centerTitle: true,
        title: const Text(
          'Kay\'s Laundry', // Logo Placeholder
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        // Default back arrow is fine, or customize if needed
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea( // Ensure content avoids notches/system areas
        child: SingleChildScrollView( // Allows scrolling if content overflows
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Full Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.name,
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

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                    // TODO: Add country code handling if needed
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // TODO: Add more specific phone number validation
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
                    hintText: '8+ characters', // Validation hint
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
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
                  title: RichText( // Use RichText for link styling
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
                           // TODO: Add recognizer to handle tap for Terms link
                           // recognizer: TapGestureRecognizer()..onTap = () { print('Terms tapped'); },
                         ),
                       ],
                     ),
                   ),
                  value: _agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading, // Checkbox on left
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24.0),

                // Create Account Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Primary button color
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Slightly rounded
                          ),
                          minimumSize: const Size(double.infinity, 48), // Full width, 48px height
                        ),
                        child: const Text('Create Account', style: TextStyle(fontSize: 16)),
                      ),
                const SizedBox(height: 16.0),

                // Back to Login Link
                TextButton(
                  onPressed: () {
                    // Navigate back to Login Screen
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