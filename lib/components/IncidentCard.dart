import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onDoubleTap: () {
                _launchGoogleMaps();
              },
              child: Container(
                height: 200,
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
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              title: 'Descripción:',
              content: description,
              icon: Icons.description,
            ),
            _buildDetailRow(
              title: 'Fecha:',
              content: date,
              icon: Icons.date_range,
            ),
            _buildDetailRow(
              title: 'Dirección:',
              content: address,
              icon: Icons.place,
            ),
            _buildDetailRow(
              title: 'Distrito:',
              content: district,
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),
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

  Widget _buildDetailRow({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  _launchGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}