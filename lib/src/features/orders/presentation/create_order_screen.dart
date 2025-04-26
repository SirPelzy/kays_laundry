import 'order_summary_screen.dart'; // Import the summary screen
// lib/src/features/orders/presentation/create_order_screen.dart
import 'package:flutter/material.dart';
import '../../services/domain/laundry_service.dart'; // Import the service model

class CreateOrderScreen extends StatefulWidget {
  final LaundryService selectedService;
  final List<LaundryService> allServices; // Needed for the service dropdown

  const CreateOrderScreen({
    super.key,
    required this.selectedService,
    required this.allServices,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  late LaundryService _currentSelectedService; // Manage currently selected service
  final _quantityController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _ifeAddressController = TextEditingController();

  // --- Dropdown Options ---
  // TODO: Potentially fetch these from a config/backend later
  final List<String> _locations = [
    'Awolowo Hall',
    'Fajuyi Hall',
    'Moremi Hall',
    'Akintola Hall',
    'Angola Hall',
    'ETF Hall',
    'Other (Ife Environs)', // Special value to trigger address field
  ];
  final List<String> _timeSlots = ['Morning (8am-12pm)', 'Afternoon (12pm-4pm)', 'Evening (4pm-8pm)'];
  // --- End Dropdown Options ---


  String? _selectedLocation;
  String? _selectedTimeSlot;
  bool _showIfeAddressField = false;

  @override
  void initState() {
    super.initState();
    _currentSelectedService = widget.selectedService; // Initialize with passed service
  }

   @override
  void dispose() {
    _quantityController.dispose();
    _instructionsController.dispose();
    _ifeAddressController.dispose();
    super.dispose();
  }

  // --- CORRECTED _reviewOrder Method ---
  void _reviewOrder() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Validation passed

      // 1. Ensure quantity is parsed correctly to double
      final double quantity = double.tryParse(_quantityController.text) ?? 0.0;
      // We assume validation already checked if it's a valid number > 0

      final String instructions = _instructionsController.text;

      // 2. Use null assertion (!) for location and timeSlot
      // We are sure they are not null here because validation passed
      final String location = _selectedLocation!;
      final String timeSlot = _selectedTimeSlot!;

      final String? ifeAddress = _showIfeAddressField ? _ifeAddressController.text.trim() : null; // Also trim address

      // --- Navigation with Correct Types ---
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSummaryScreen(
            service: _currentSelectedService,
            quantity: quantity,           // Pass the double
            instructions: instructions,
            location: location,           // Pass the non-nullable String
            ifeAddress: ifeAddress,
            timeSlot: timeSlot,           // Pass the non-nullable String
          ),
        ),
      );
      // --- End Navigation ---

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
    }
  }
  // --- End CORRECTED _reviewOrder Method ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
        backgroundColor: Colors.white, // Light gray header could also be Colors.grey[100]
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Service Selection ---
              Text('Selected Service', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              // Using Dropdown to allow changing service as per prompt
              DropdownButtonFormField<LaundryService>(
                value: _currentSelectedService,
                items: widget.allServices.map((service) {
                  return DropdownMenuItem<LaundryService>(
                    value: service, // Use the service object itself as the value
                    child: Text(service.name),
                  );
                }).toList(),
                onChanged: (LaundryService? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentSelectedService = newValue;
                      // Clear quantity if unit changes, maybe? For simplicity, don't for now.
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                ),
                validator: (value) => value == null ? 'Please select a service' : null,
              ),
              const SizedBox(height: 20),

              // --- Quantity ---
              Text('Quantity (${_currentSelectedService.unit})', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Enter quantity in ${_currentSelectedService.unit}',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shopping_basket_outlined),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: _currentSelectedService.unit == 'kg'), // Allow decimal for kg
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final number = double.tryParse(value);
                  if (number == null) {
                     return 'Please enter a valid number';
                  }
                  if (number <= 0) {
                    return 'Quantity must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Special Instructions ---
               Text('Special Instructions (Optional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'E.g., "Use hypoallergenic detergent"',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Better alignment for multi-line
                ),
                maxLines: 3, // Make it a text area
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // --- Pickup / Delivery ---
              Text('Pickup & Delivery', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              // Location Dropdown
               Text('Location', style: Theme.of(context).textTheme.titleMedium),
               const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                hint: const Text('Select pickup/delivery location'),
                items: _locations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                    // Show/hide Ife address field based on selection
                    _showIfeAddressField = (newValue == 'Other (Ife Environs)');
                    if (!_showIfeAddressField) {
                       _ifeAddressController.clear(); // Clear address if hostel selected
                    }
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                ),
                 validator: (value) => value == null ? 'Please select a location' : null,
              ),
              const SizedBox(height: 16),

              // Conditional Ife Address Field
              if (_showIfeAddressField)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Specify Ife Address', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ifeAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Enter full address and landmark',
                        border: OutlineInputBorder(),
                         prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (_showIfeAddressField && (value == null || value.trim().isEmpty)) {
                          return 'Please enter the specific address in Ife';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),


              // Time Slot Dropdown
              Text('Preferred Time Slot', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTimeSlot,
                hint: const Text('Select pickup/delivery time'),
                items: _timeSlots.map((time) {
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTimeSlot = newValue;
                  });
                },
                 decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                   contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                ),
                 validator: (value) => value == null ? 'Please select a time slot' : null,
              ),
              const SizedBox(height: 32),

              // Review Order Button
              ElevatedButton(
                onPressed: _reviewOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Review Order', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}