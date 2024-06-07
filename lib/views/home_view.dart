import 'package:flutter/material.dart';
import 'package:citysos_police/api/incident_service.dart';

import '../components/IncidentCard.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Map<String, dynamic>>> _futureIncidents;

  @override
  void initState() {
    super.initState();
    _futureIncidents = IncidentService().getPendingIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: () {
              },
            ),
            const SizedBox(width: 8.0),
            Text(
              'Incidentes pendientes',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureIncidents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se han encontrado incidentes pendientes'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final incident = snapshot.data![index];
                return IncidentCard(
                  description: incident['description'],
                  date: incident['date'],
                  address: incident['address'],
                  district: incident['district'],
                  latitude: incident['latitude'],
                  longitude: incident['longitude'],
                  status: incident['status'],
                );
              },
            );
          }
        },
      ),
    );
  }
}
