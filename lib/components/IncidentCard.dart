import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IncidentCard extends StatelessWidget {
  final String description;
  final String date;
  final String address;
  final String district;
  final double latitude;
  final double longitude;
  final String status;

  const IncidentCard({
    Key? key,
    required this.description,
    required this.date,
    required this.address,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Description:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Date:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Address:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'District:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                district,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Status:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200, // Adjust the height as needed
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(latitude, longitude),
                  zoom: 12,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('incident_location'),
                    position: LatLng(latitude, longitude),
                  ),
                },
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add your onPressed logic here
                },
                child: Text('Aceptar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}