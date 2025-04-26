// lib/src/features/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../orders/presentation/order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Placeholder User Data ---
  // TODO: Fetch user data from FirebaseAuth or your backend based on UID
  String _userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User'; // Get name from Firebase if available
  String _userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No email'; // Get email from Firebase
  String _userPhone = '+234 801 234 5678'; // Phone still placeholder
  // --- End Placeholder Data ---

  // --- Helper to get initials ---
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> names = name.trim().split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0]; // First initial
    }
    if (names.length > 1) {
      initials += names[names.length - 1][0]; // Last initial
    }
    return initials.toUpperCase();
  }

  // --- Logout Function ---
  Future<void> _logout() async {
     // Optional: Show confirmation dialog
     final bool? confirm = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Confirm Logout'),
         content: const Text('Are you sure you want to log out?'),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(false), // Return false on cancel
             child: const Text('Cancel'),
           ),
           TextButton(
             onPressed: () => Navigator.of(context).pop(true), // Return true on confirm
             child: const Text('Logout'),
             style: TextButton.styleFrom(foregroundColor: Colors.red),
           ),
         ],
       ),
     );

     // Proceed only if user confirmed (confirm == true)
     if (confirm == true) {
        try {
          print('Logging out user...');
          await FirebaseAuth.instance.signOut();
          print('User logged out successfully.');
          // No need to navigate here, the auth state listener in app.dart will handle it
        } catch (e) {
           print('Error logging out: $e');
           // Show error message if needed
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error logging out: ${e.toString()}')),
           );
        }
     }
  }


  @override
  Widget build(BuildContext context) {
    // Update user details whenever the screen builds (in case they change)
     _userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
     _userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Initials Circle
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade600,
              child: Text(
                _getInitials(_userName),
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // User Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDetailItem(Icons.person_outline, 'Name', _userName),
                    const Divider(height: 20),
                    _buildDetailItem(Icons.email_outlined, 'Email', _userEmail),
                    const Divider(height: 20),
                    _buildDetailItem(Icons.phone_outlined, 'Phone', _userPhone), // Still placeholder
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profile'),
                        onPressed: () {
                          // TODO: Implement Edit Profile action
                          print('Edit Profile button pressed');
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Edit Profile Not Implemented Yet')),
                           );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Options List
            _buildOptionItem(
              icon: Icons.history_outlined,
              title: 'Order History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {
                // TODO: Implement navigation to Help Center/FAQ screen or action
                print('Navigate to Help Center');
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Help Center Not Implemented Yet')),
                 );
              },
            ),
             const Divider(height: 20, indent: 16, endIndent: 16), // Separator before logout
            _buildOptionItem(
              icon: Icons.logout_outlined,
              title: 'Logout',
              iconColor: Colors.red.shade600,
              textColor: Colors.red.shade700,
              onTap: _logout, // Call the logout function
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for displaying user detail items
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for building list options (Order History, Help, Logout)
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: textColor ?? Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    );
  }
}
