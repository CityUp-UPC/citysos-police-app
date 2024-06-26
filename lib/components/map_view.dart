import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapView({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? mapController; // Make mapController nullable

  bool isMapCreated = false; // Track if the map is created

  @override
  void dispose() {
    if (isMapCreated && mapController != null) {
      mapController!.dispose(); // Dispose only if mapController is not null and map is created
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          setState(() {
            isMapCreated = true; // Update the map created status
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('incident_location'),
            position: LatLng(widget.latitude, widget.longitude),
          ),
        },
      ),
    );
  }
}