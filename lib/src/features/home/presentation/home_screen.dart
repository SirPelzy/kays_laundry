// lib/src/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import '../../services/domain/laundry_service.dart'; // Import the model
import '../../orders/presentation/create_order_screen.dart'; // Import create order screen
import '../../../core/services/api_service.dart'; // Import the ApiService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService(); // Instance of our API service
  List<LaundryService> _allServices = []; // Holds all fetched services
  List<LaundryService> _filteredServices = []; // Holds services after filtering
  final _searchController = TextEditingController();

  // State variables for loading and error handling
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchServices(); // Fetch services when the screen loads
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  // --- Method to Fetch Services ---
  Future<void> _fetchServices() async {
    // Ensure state is updated correctly before potential async gaps
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final services = await _apiService.getLaundryServices();
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _allServices = services;
          _filteredServices = services; // Initially show all services
          _isLoading = false;
        });
      }
    } catch (e) {
       print("HomeScreen: Error fetching services: $e"); // Log error
       if (mounted) {
         setState(() {
           _errorMessage = e.toString(); // Show error message on screen
           _isLoading = false;
         });
       }
    }
  }

  // --- Filtering Logic (remains the same) ---
  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _allServices.where((service) {
        return service.name.toLowerCase().contains(query) ||
               service.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Kay\'s Laundry', // Updated name
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.grey),
            tooltip: 'Profile',
            onPressed: () {
              // Navigation handled by MainScaffold's bottom nav
              // Find the ScaffoldMessenger ancestor correctly
              final scaffoldState = Scaffold.maybeOf(context);
              if (scaffoldState != null) {
                 // You might want to navigate explicitly here if needed,
                 // but usually bottom nav handles this state change.
                 print('Profile icon pressed (handled by bottom nav)');
              } else {
                 print('Profile icon pressed (Scaffold not found)');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              enabled: !_isLoading, // Disable search while loading
            ),
          ),

          // --- Content Area (Loading/Error/List) ---
          Expanded(
            child: _buildContentArea(),
          ),
        ],
      ),
    );
  }

  // --- Helper to build main content based on state ---
  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(Icons.error_outline, color: Colors.red.shade400, size: 50),
               const SizedBox(height: 16),
               Text(
                 'Failed to load services',
                 style: Theme.of(context).textTheme.titleMedium,
                 textAlign: TextAlign.center,
               ),
                const SizedBox(height: 8),
               Text(
                 _errorMessage!, // Show specific error
                 style: Theme.of(context).textTheme.bodySmall,
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 20),
               ElevatedButton.icon(
                 icon: const Icon(Icons.refresh),
                 label: const Text('Retry'),
                 onPressed: _fetchServices, // Call fetch again
               )
             ],
          ),
        ),
      );
    }

    if (_filteredServices.isEmpty && _searchController.text.isEmpty) {
       // Handle case where API returns empty list initially
       return const Center(child: Text('No laundry services available at the moment.'));
    }

     if (_filteredServices.isEmpty && _searchController.text.isNotEmpty) {
       // Handle case where search yields no results
       return Center(child: Text('No services found matching "${_searchController.text}".'));
    }

    // Display the list if data is loaded and not empty
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return _buildServiceCard(service); // Use the existing card builder
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }


  // Helper Widget to build each service card (Adjusted for missing icon)
  Widget _buildServiceCard(LaundryService service) {
    // --- Assign placeholder icons based on service name (Example) ---
    IconData serviceIcon = Icons.local_laundry_service_outlined; // Default
    if (service.name.toLowerCase().contains('iron')) {
      serviceIcon = Icons.iron_outlined;
    } else if (service.name.toLowerCase().contains('dry clean')) {
       serviceIcon = Icons.dry_cleaning_outlined;
    }
    // --- End Placeholder Icon Logic ---

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use the assigned placeholder icon
                Icon(serviceIcon, size: 36.0, color: Colors.blue),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        service.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₦${service.pricePerUnit.toStringAsFixed(0)} / ${service.unit}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Create Order Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrderScreen(
                          selectedService: service,
                          // Pass all services for the dropdown in create screen
                          allServices: _allServices,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  ),
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
