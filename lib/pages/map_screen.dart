import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _initialPosition =
      const LatLng(40.7128, -74.0060); // New York coordinates (default)
  bool _isMapReady = false; // For map readiness
  bool _locationPermissionGranted = false; // To track if permission is granted

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Check permissions when screen starts
  }

  // Check and request location permissions
  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _getCurrentLocation(); // Get the current location after permission is granted
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Request permission
      if (await Permission.location.request().isGranted) {
        setState(() {
          _locationPermissionGranted = true;
        });
        _getCurrentLocation(); // Get the current location after permission is granted
      } else {
        // If permission is denied, inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to show the map'),
          ),
        );
      }
    }
  }

  // Get the current location using Geolocator
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Update the initial position to the current location
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });

    // Move the camera to the current location if the map is ready
    if (_isMapReady) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _initialPosition,
            zoom: 15.0, // Zoom level for a closer look at the current location
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _isMapReady = true; // Set map ready when created
    });

    // Move the camera to the current location if the permission is granted
    if (_locationPermissionGranted) {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Example'),
      ),
      body: _locationPermissionGranted
          ? GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 10.0,
              ),
              zoomControlsEnabled: true,
              myLocationEnabled: true, // Shows the blue dot for user's location
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              buildingsEnabled: true,
            )
          : const Center(child: Text('Requesting Location Permission...')),
    );
  }
}
