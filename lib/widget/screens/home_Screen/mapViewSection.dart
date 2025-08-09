import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapviewsection extends StatefulWidget {
  const Mapviewsection({super.key});

  @override
  State<Mapviewsection> createState() => _MapviewsectionState();
}

class _MapviewsectionState extends State<Mapviewsection> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};

  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }
  // final Set<Marker> _markers = {
  //   Marker(
  //     markerId: MarkerId('colombo'),
  //     position: LatLng(6.9271, 79.8612),
  //     infoWindow: InfoWindow(title: 'Colombo', snippet: 'Capital of Sri Lanka'),
  //   ),
  // };

  // Check if location services are enabled

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location Services are disabled.');
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition();

    setState(() {
      _initialPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16,
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    });

    // Wait for mapController to be initialized before calling animateCamera

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore by Map',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _initialPosition,
                markers: _markers,
                zoomControlsEnabled: false,
                myLocationEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
