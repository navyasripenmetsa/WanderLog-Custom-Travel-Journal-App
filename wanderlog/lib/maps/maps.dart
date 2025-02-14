import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlacesSearchScreen(),
    );
  }
}

class PlacesSearchScreen extends StatefulWidget {
  @override
  _PlacesSearchScreenState createState() => _PlacesSearchScreenState();
}

class _PlacesSearchScreenState extends State<PlacesSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  static const String apiKey =
      "AIzaSyCOr_KyM48c7Uu_2Pk21yXdItisrZbCR10"; // Replace with your API Key

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('assets/map_style.json');
    _mapController?.setMapStyle(style);
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text;
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        setState(() {
          _selectedLocation = LatLng(loc.latitude, loc.longitude);
          _markers.clear();
        });
        _mapController
            ?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 14));
        _fetchNearbyPlaces(loc.latitude, loc.longitude);
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  void _showPlaceDetails(dynamic place, String? photoReference) {
    // Generate image URL only if photoReference is valid
    String imageUrl = (photoReference != null && photoReference.isNotEmpty)
        ? "https://maps.googleapis.com/maps/api/place/photo"
            "?maxwidth=400"
            "&photo_reference=$photoReference"
            "&key=$apiKey"
        : ""; // Empty URL if there's no photo

    print("Generated Image URL: $imageUrl"); // Debugging

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place['name'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Show image if a valid URL exists, otherwise show a placeholder
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  height: 150,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print("Image failed to load: $error");
                    return Image.asset('assets/no_image_available.png',
                        height: 150);
                  },
                )
              else
                Text("No image available"),

              SizedBox(height: 10),
              Text("⭐ Rating: ${place['rating'] ?? 'N/A'}"),
              if (place.containsKey('vicinity'))
                Text("📍 Location: ${place['vicinity']}"),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchNearbyPlaces(double lat, double lng) async {
    String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        "location=$lat,$lng&radius=10000&type=tourist_attraction&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> places = data['results'];

        List<dynamic> topPlaces = places
            .where((place) =>
                place.containsKey('rating') && place['rating'] >= 4.0)
            .toList();
        topPlaces.sort((a, b) => b['rating'].compareTo(a['rating']));

        setState(() {
          _markers.clear();
          _markers.addAll(topPlaces.map((place) {
            String? photoReference =
                place['photos']?[0]['photo_reference']; // Fetch first photo
            print("Photo Reference: $photoReference");
            String imageUrl = photoReference != null
                ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReference&key=$apiKey"
                : "https://via.placeholder.com/400"; // Fallback image

            return Marker(
              markerId: MarkerId(place['name']),
              position: LatLng(
                place['geometry']['location']['lat'],
                place['geometry']['location']['lng'],
              ),
              infoWindow: InfoWindow(
                title: place['name'],
                snippet: "Rating: ${place['rating'] ?? 'N/A'}",
                onTap: () => _showPlaceDetails(place, imageUrl),
              ),
            );
          }));
        });
      } else {
        print("Failed to fetch places: ${response.body}");
      }
    } catch (e) {
      print("Error fetching nearby places: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Travel Guide")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Enter city, area, or tourist spot",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(20.5937, 78.9629),
                zoom: 5,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                _loadMapStyle();
              },
            ),
          ),
        ],
      ),
    );
  }
}
