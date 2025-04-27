// lib/src/core/services/api_service.dart
import 'dart:convert'; // For jsonDecode
// Import the http package with an alias 'http'
import 'package:http/http.dart' as http;
// Import the LaundryService model
import '../../features/services/domain/laundry_service.dart';

// A service class to handle interactions with the backend API
class ApiService {
  // No base URL is needed when the frontend and backend are served from the same origin.
  // The browser will automatically use the current origin for relative paths.

  // Method to fetch the list of laundry services from the backend
  Future<List<LaundryService>> getLaundryServices() async {
    // Define the relative path to the API endpoint.
    // It's crucial this matches the route defined in your backend (server.js).
    const String relativePath = '/api/services';
    // Uri.parse works correctly with relative paths like this.
    final Uri url = Uri.parse(relativePath);

    // Log the attempt to fetch data for debugging purposes.
    print('ApiService: Fetching services from relative path: $relativePath');

    try {
      // Make the HTTP GET request to the constructed URL.
      final response = await http.get(url);

      // Log the status code received from the backend.
      print('ApiService: Response status code: ${response.statusCode}');
      // Uncomment the line below to see the raw response body for debugging.
      // print('ApiService: Response body: ${response.body}');

      // Check if the request was successful (status code 200 OK).
      if (response.statusCode == 200) {
        // Decode the JSON response body (which is expected to be a List).
        List<dynamic> body = jsonDecode(response.body);
        // Map the list of dynamic JSON objects to a list of LaundryService objects
        // using the fromJson factory constructor defined in the model.
        List<LaundryService> services = body
            .map((dynamic item) => LaundryService.fromJson(item as Map<String, dynamic>))
            .toList();
        // Log successful parsing.
        print('ApiService: Successfully parsed ${services.length} services.');
        return services;
      } else {
        // If the server returned an error status code, throw an exception.
        print('ApiService: Failed to load services. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load laundry services (Status code: ${response.statusCode})');
      }
    } catch (e) {
      // Catch any other errors during the request (network issues, parsing errors).
       print('ApiService: Error fetching services: $e');
       // Check if the error is a FormatException likely caused by receiving HTML (e.g., an error page) instead of JSON.
       if (e is FormatException && e.source is String && (e.source as String).contains('<html')) {
          throw Exception('Failed to connect to API. Is the backend running and serving correctly? Received HTML instead of JSON.');
       }
       // Re-throw other exceptions to be handled by the calling code (e.g., the UI).
       throw Exception('Error connecting to the server: $e');
    }
  }

  // TODO: Add methods for creating orders (POST /api/orders), fetching history (GET /api/orders), etc. later,
  // ensuring they also use relative paths like '/api/orders'.
}
