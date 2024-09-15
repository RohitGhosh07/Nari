import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  final List<Marker> _markers = [];
  bool _loading = true;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    while (true) {
      final permissionStatus = await Permission.location.status;

      if (permissionStatus.isGranted) {
        _getCurrentLocation();
        break;
      } else if (permissionStatus.isDenied ||
          permissionStatus.isPermanentlyDenied) {
        _showPermissionDialog();
        await Future.delayed(
            Duration(seconds: 5)); // Wait for the user to decide
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from being dismissed
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(
            'We need location access to show your current location and nearby places. Please grant location access.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermission();
            },
            child: Text('Grant Permission'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _loading = false;
      });

      _mapController.move(LatLng(position.latitude, position.longitude), 14.0);

      _addNearbyMarkers(position);
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void _addNearbyMarkers(Position position) {
    _markers.add(
      Marker(
        point: LatLng(position.latitude + 0.01, position.longitude + 0.01),
        width: 80,
        height: 80,
        child: Icon(Icons.local_police, color: Colors.blue),
      ),
    );

    _markers.add(
      Marker(
        point: LatLng(position.latitude - 0.01, position.longitude - 0.01),
        width: 80,
        height: 80,
        child: Icon(Icons.local_hospital, color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modern Map UI'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for places...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (query) {
                      // Handle search functionality here
                    },
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(_currentPosition?.latitude ?? 0.0,
                          _currentPosition?.longitude ?? 0.0),
                      initialZoom: 14.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: _markers,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
