import '../../orders/presentation/order_history_screen.dart'; // Import order history screen
// lib/src/features/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Placeholder User Data ---
  // TODO: Replace with actual user data fetched from auth/backend
  String _userName = 'Pelumi Ade';
  String _userEmail = 'pelumi.ade@example.com';
  String _userPhone = '+234 801 234 5678';
  // --- End Placeholder Data ---

  // TODO: Add state for editing mode if implementing inline editing
  // bool _isEditing = false;

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

  @override
  Widget build(BuildContext context) {
    // This Scaffold is nested within the MainScaffold's body
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white, // Or Colors.grey[100] for light gray header
        foregroundColor: Colors.black87,
        elevation: 1,
        // No back button needed here as it's a main tab screen
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
                    _buildDetailItem(Icons.phone_outlined, 'Phone', _userPhone),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profile'),
                        onPressed: () {
                          // TODO: Implement Edit Profile action
                          // Could navigate to a separate Edit Profile screen
                          // Or toggle an inline editing mode
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
                
                print('Navigate to Order History');
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Order History Not Implemented Yet')),
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
              iconColor: Colors.red.shade600, // Make logout visually distinct
              textColor: Colors.red.shade700,
              onTap: () {
                // TODO: Implement Logout logic
                // 1. Show confirmation dialog
                // 2. Clear user session/token
                // 3. Navigate back to Login Screen
                print('Logout button pressed');
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Logout Not Implemented Yet')),
                 );
              },
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
    Color? iconColor, // Optional color override
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
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Adjust padding
      // Ensure touch target size is sufficient via ListTile's default padding
    );
  }
}
