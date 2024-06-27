import 'dart:async';
import 'package:flutter/material.dart';
import 'package:citysos_police/api/incident_service.dart';
import 'package:citysos_police/components/incident_card.dart';
import 'package:citysos_police/components/incident_inprogress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/auth_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _incidents = [];
  List<Map<String, dynamic>> _inProgressIncidents = [];
  final IncidentService _incidentService = IncidentService();
  Timer? _timer;
  late AuthProvider _authProvider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _authProvider.addListener(_onAuthProviderChange);
    _fetchInitialData();
    _startPolling();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthProviderChange);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onAuthProviderChange() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      _refreshIncidents();
    }
  }

  void _startPolling() {
    const pollInterval = Duration(seconds: 5);
    _timer = Timer.periodic(pollInterval, (timer) {
      _refreshIncidents();
    });
  }

  Future<void> _fetchInitialData() async {
    await _refreshIncidents();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshIncidents() async {
    try {
      final pendingIncidents = await _incidentService.getPendingIncidents();
      final inProgressIncidents = await _incidentService.getInProgressIncidentsByPoliceId();
      setState(() {
        _incidents = pendingIncidents;
        _inProgressIncidents = inProgressIncidents;
      });
    } catch (error) {
      print('Error fetching incidents: $error');
    }
  }

  void _handleIncidentFinished(int id) {
    // Remove the finished incident from _inProgressIncidents list
    setState(() {
      _inProgressIncidents.removeWhere((incident) => incident['id'] == id);
    });
  }

  void _handleIncidentJoin() {
    _refreshIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.crisis_alert_rounded, color: Colors.white),
              onPressed: () {
                // Handle home button pressed
              },
            ),
            const SizedBox(width: 8.0),
            Text(
              'Incidentes pendientes',
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inProgressIncidents.isNotEmpty
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Incidentes atendiendo',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _inProgressIncidents.length,
              itemBuilder: (context, index) {
                final incident = _inProgressIncidents[index];
                return IncidentInProgressCard(
                  id: incident['id'],
                  description: incident['description'],
                  date: incident['date'],
                  address: incident['address'],
                  district: incident['district'],
                  latitude: incident['latitude'],
                  longitude: incident['longitude'],
                  status: incident['status'],
                  onIncidentFinished: _handleIncidentFinished, // Pass callback function
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Adjust the margin as needed
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Incidentes pendientes'),
                        content: SizedBox(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          child: ListView.builder(
                            itemCount: _incidents.length,
                            itemBuilder: (context, index) {
                              final incident = _incidents[index];
                              return IncidentCard(
                                id: incident['id'],
                                description: incident['description'],
                                date: incident['date'],
                                address: incident['address'],
                                district: incident['district'],
                                latitude: incident['latitude'],
                                longitude: incident['longitude'],
                                status: incident['status'],
                                onIncidentAccepted: _handleIncidentJoin, // Pass callback function
                              );
                            },
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                ),
                child: const Text(
                  'Ver incidentes pendientes',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      )
          : _incidents.isEmpty
          ? const Center(child: Text('No se han encontrado incidentes pendientes'))
          : ListView.builder(
        itemCount: _incidents.length,
        itemBuilder: (context, index) {
          final incident = _incidents[index];
          return IncidentCard(
            id: incident['id'],
            description: incident['description'],
            date: incident['date'],
            address: incident['address'],
            district: incident['district'],
            latitude: incident['latitude'],
            longitude: incident['longitude'],
            status: incident['status'],
            onIncidentAccepted: _handleIncidentJoin, // Pass callback function
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          _refreshIncidents(); // Refresh incidents when floating button is pressed
        },
        tooltip: 'Refrescar',
        backgroundColor: Colors.grey,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
          size: 24.0,
        ),
      ),
    );
  }
}