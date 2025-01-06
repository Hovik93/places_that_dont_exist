// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:places_that_dont_exist/base/colors.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';

// ignore: must_be_immutable
class MapPage extends StatefulWidget {
  String? title;
  MapPage({
    super.key,
    this.title,
  });

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
    final TextTheme theme = Theme.of(context).textTheme;
    final customTheme = Theme.of(context).extension<CustomTheme>();
    return Scaffold(
      body: body(theme: theme, customTheme: customTheme),
    );
  }

  Widget body({required TextTheme theme, required customTheme}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: customTheme?.gradientBackground,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 10.w,
              ),
              child: appBar(theme: theme, customTheme: customTheme),
            ),
            Expanded(
              child: bodyBlock(theme: theme, customTheme: customTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar({required TextTheme? theme, required customTheme}) {
    return BottomBorderContainer(
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 26.w, bottom: 15, right: 26.w),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title ?? '',
                overflow: TextOverflow.ellipsis,
                style: theme?.bodySmall
                    ?.copyWith(fontSize: 17, color: AppColors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyBlock({required TextTheme theme, required customTheme}) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
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
                    latLong: LatLong(latitude: 48.864716, longitude: 2.349014),
                    marker: Icon(
                      Icons.circle_outlined,
                      color: Colors.green,
                      size: 40,
                    )),
                SimpleMapMarker(
                    markerSize: Size(16, 16),
                    latLong: LatLong(latitude: 52.520008, longitude: 13.404954),
                    marker: Icon(
                      Icons.circle_outlined,
                      color: Colors.green,
                      size: 16,
                    )),

                SimpleMapMarker(
                    markerSize: Size(16, 16),
                    latLong: LatLong(latitude: 51.507351, longitude: -0.127758),
                    marker: Icon(
                      Icons.circle_outlined,
                      color: Colors.green,
                      size: 16,
                    )),

                // BOGOTA
                SimpleMapMarker(
                    markerSize: Size(16, 16),
                    latLong: LatLong(latitude: 4.710989, longitude: -74.072092),
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
