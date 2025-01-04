import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // final List<Map<String, dynamic>> markers = [
  //   {'name': 'Marker 1', 'latitude': 48.8566, 'longitude': 2.3522}, // Париж
  //   {
  //     'name': 'Marker 2',
  //     'latitude': 40.7128,
  //     'longitude': -74.0060
  //   }, // Нью-Йорк
  //   {'name': 'Marker 3', 'latitude': 35.6895, 'longitude': 139.6917}, // Токио
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Markers'),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: InteractiveViewer(
              maxScale: 20.0,
              child: SimpleMap(
                instructions: SMapWorld.instructionsMercator,
                defaultColor: Colors.grey,
                countryBorder: CountryBorder(color: Colors.green),
                colors: SMapWorldColors().toMap(),
                callback: (id, name, details) {
                  debugPrint('Tapped on country: $name ($id)');
                },
                markers: [
                  SimpleMapMarker(
                      markerSize: Size(16, 16),
                      latLong:
                          LatLong(latitude: 48.864716, longitude: 2.349014),
                      marker: Icon(
                        Icons.circle_outlined,
                        color: Colors.green,
                        size: 40,
                      )),
                  SimpleMapMarker(
                      markerSize: Size(16, 16),
                      latLong:
                          LatLong(latitude: 52.520008, longitude: 13.404954),
                      marker: Icon(
                        Icons.circle_outlined,
                        color: Colors.green,
                        size: 16,
                      )),

                  SimpleMapMarker(
                      markerSize: Size(16, 16),
                      latLong:
                          LatLong(latitude: 51.507351, longitude: -0.127758),
                      marker: Icon(
                        Icons.circle_outlined,
                        color: Colors.green,
                        size: 16,
                      )),

                  // BOGOTA
                  SimpleMapMarker(
                      markerSize: Size(16, 16),
                      latLong:
                          LatLong(latitude: 4.710989, longitude: -74.072092),
                      marker: Icon(
                        Icons.circle_outlined,
                        color: Colors.green,
                        size: 16,
                      )),

                  // NEW YORK

                  SimpleMapMarker(
                      markerSize: Size(16, 16),
                      latLong:
                          LatLong(latitude: 40.730610, longitude: -73.935242),
                      marker: Icon(
                        Icons.circle_outlined,
                        color: Colors.green,
                        size: 16,
                      )),

                  // TOKYO
                  SimpleMapMarker(
                      markerSize: Size(16, 16),
                      latLong:
                          LatLong(latitude: 35.652832, longitude: 139.839478),
                      marker: Icon(
                        Icons.circle_outlined,
                        color: Colors.green,
                        size: 16,
                      )),

                  // // TORONTO
                  SimpleMapMarker(
                      markerSize: Size(16, 16),
                      latLong:
                          LatLong(latitude: 43.651070, longitude: -79.347015),
                      marker: Icon(
                        Icons.circle_outlined,
                        color: Colors.green,
                        size: 16,
                      )),
                ],
                // key: Key(properties.toString()),
                // colors: keyValuesPaires,
                // instructions: SMapCanada.instructions,
                // callback: (id, name, tapDetails) {
                //   print('id: $id, name: $name');
                // },
                // callback: (id, name, tapDetails) {
                //   setState(() {
                //     state = name;

                //     int i = properties
                //         .indexWhere((element) => element['id'] == id);

                //     properties[i]['color'] =
                //         properties[i]['color'] == Colors.green
                //             ? null
                //             : Colors.green;
                //     keyValuesPaires[properties[i]['id']] =
                //         properties[i]['color'];
                //   });
                // },
                // ))));
                // ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showMarkerDialog(String? markerName) {
    if (markerName == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(markerName),
        content: const Text('Marker information goes here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (!latitude.isFinite || !longitude.isFinite) return false;
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180)
      return false;
    return true;
  }
}
