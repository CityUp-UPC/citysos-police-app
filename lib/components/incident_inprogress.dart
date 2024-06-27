
import 'package:citysos_police/api/feeds_service.dart';
import 'package:citysos_police/api/incident_service.dart';
import 'package:citysos_police/components/incident_feed_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class IncidentInProgressCard extends StatefulWidget {
  final int id;
  final String description;
  final String date;
  final String address;
  final String district;
  final double latitude;
  final double longitude;
  final String status;
  final Function(int) onIncidentFinished; // Callback function

  const IncidentInProgressCard({
    Key? key,
    required this.id,
    required this.description,
    required this.date,
    required this.address,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.onIncidentFinished, // Callback function passed in constructor
  }) : super(key: key);

  @override
  _IncidentInProgressCardState createState() => _IncidentInProgressCardState();
}

class _IncidentInProgressCardState extends State<IncidentInProgressCard> {
  List<Map<String, dynamic>> _feeds = [];
  String _newComment = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFeeds();
  }

  Future<void> _fetchFeeds() async {
    isLoading = true;
    var _feedService = FeedsService();

    _feedService.getFeedsByIncidentId(widget.id)
    .then((feeds) {
      setState(() {
        _feeds = feeds;
        isLoading = false;
      });
    })
    .catchError((error) {
      print('Error fetching feeds: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _pushFeed(String comment) async {
    var _feedService = FeedsService();

      _feedService.postFeed(widget.id, comment)
      .then((response) {
        _fetchFeeds();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentario enviado')),
        );
        setState(() {
          _newComment = ''; // Clear input field
        });
      })
      .catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hubo un error. Por favor, inténtelo de nuevo')),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(widget.date));

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
              onDoubleTap: _launchGoogleMaps,
              child: SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.latitude, widget.longitude),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('incident_location'),
                      position: LatLng(widget.latitude, widget.longitude),
                    ),
                  },
                  liteModeEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              title: 'Descripción:',
              content: widget.description,
              icon: Icons.description,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              title: 'Fecha:',
              content: formattedDate,
              icon: Icons.date_range,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              title: 'Dirección:',
              content: widget.address,
              icon: Icons.place,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              title: 'Distrito:',
              content: widget.district,
              icon: Icons.location_city,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              title: 'Estado:',
              content: widget.status,
              icon: Icons.help_outline_rounded,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _finishIncident(context),
                    child: const Text('Finalizar incidente'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _requestHelp(context),
                    child: const Text('Solicitar apoyo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: const Text('Feed de incidentes'),
                                content: isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      height: 300,
                                      child: ListView.builder(
                                        itemCount: _feeds.length,
                                        itemBuilder: (context, index) {
                                          final feed = _feeds[index];
                                          return IncidentFeedCard(
                                            police: feed['police']['user']['firstName'] +
                                                ' ' +
                                                feed['police']['user']['lastName'],
                                            comment: feed['comment'],
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _newComment = value; // Update new comment
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Escriba un comentario...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cerrar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle sending the new comment here
                                      if (_newComment.isNotEmpty) {
                                        _pushFeed(_newComment); // Call _pushFeed with new comment
                                      }
                                    },
                                    child: const Text('Enviar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: const Text('Ver feeds'),
                  ),
                ),
              ],
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _requestHelp(BuildContext context) {
    IncidentService _incidentService = IncidentService();

    _incidentService.requestHelp(widget.id).then((response){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayuda solicitada!')),
      );
    })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al solicitar ayuda: $error')),
      );
    });
  }

  void _finishIncident(BuildContext context) {
    IncidentService _incidentService = IncidentService();

    _incidentService.completeIncidentById(widget.id).then((response) {
      if (response == true) {
        widget.onIncidentFinished(widget.id); // Invoke the callback
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Incidente finalizado'),
              content: const Text('Se ha finalizado el incidente.'),
              actions: [
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
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('No se pudo finalizar el incidente. Por favor, inténtelo de nuevo.'),
              actions: [
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
      }
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(
                'No se pudo finalizar el incidente. Por favor, inténtelo de nuevo. Error: ${error.toString()}'),
            actions: [
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
    });
  }
}