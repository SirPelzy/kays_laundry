import '../../orders/presentation/create_order_screen.dart';
// lib/src/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import '../../services/domain/laundry_service.dart'; // Import the model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Placeholder Data ---
  // TODO: Replace with data fetched from an API/backend
  final List<LaundryService> _services = const [
    LaundryService(
      id: '1',
      name: 'Wash & Fold',
      description: 'Clothes washed, dried, and neatly folded.',
      pricePerUnit: 500,
      unit: 'kg',
      icon: Icons.local_laundry_service_outlined,
    ),
    LaundryService(
      id: '2',
      name: 'Wash & Iron',
      description: 'Washed, dried, and professionally ironed.',
      pricePerUnit: 800,
      unit: 'kg',
      icon: Icons.iron_outlined,
    ),
    LaundryService(
      id: '3',
      name: 'Dry Cleaning',
      description: 'Special care for delicate garments.',
      pricePerUnit: 1500,
      unit: 'item',
      icon: Icons.dry_cleaning_outlined,
    ),
     LaundryService(
      id: '4',
      name: 'Just Ironing',
      description: 'Get your clothes professionally pressed.',
      pricePerUnit: 300,
      unit: 'item',
      icon: Icons.iron, // Using a filled icon variant here
    ),
  ];

  List<LaundryService> _filteredServices = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially, show all services
    _filteredServices = _services;
    _searchController.addListener(_filterServices);
  }

   @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        return service.name.toLowerCase().contains(query) ||
               service.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // As per theme requirements
        elevation: 1, // Subtle shadow
        title: const Text(
          'Kay\'s Laundry', // Logo Placeholder
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.grey),
            tooltip: 'Profile',
            onPressed: () {
              // TODO: Implement navigation to Profile Screen
              // Usually handled by the bottom nav, but could be explicit action
              print('Profile icon pressed');
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
                hintText: 'Search services (e.g., Wash & Fold)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none, // Remove border
                ),
                filled: true, // Need filled true for fillColor
                fillColor: Colors.grey[200], // Light gray background
              ),
            ),
          ),

          // Service List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                return _buildServiceCard(service);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12), // Spacing between cards
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget to build each service card
  Widget _buildServiceCard(LaundryService service) {
    return Card(
      elevation: 2, // Subtle shadow
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
                Icon(service.icon, size: 36.0, color: Colors.blue), // Service icon
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
                   // Using Nigeria Naira symbol (Ensure your font supports it)
                   // Alternatively use NGN or other representation
                  '₦${service.pricePerUnit.toStringAsFixed(0)} / ${service.unit}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrderScreen(
                          selectedService: service,
                          allServices: _services,
                        ),
                      ),
                    );  
                    // TODO: Implement navigation to Order Creation Screen
                    // Pass the selected service details
                    print('Selected service: ${service.name}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                     // Ensure minimum touch target size indirectly via padding/size
                  ),
                  child: const Text('Select'),
                ),
              ],
            ),
             // Ensure overall card is at least 100px high implicitly
             // You could wrap the content in a ConstrainedBox(minHeight: 100) if needed
          ],
        ),
      ),
    );
  }
}