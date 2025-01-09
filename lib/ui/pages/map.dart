// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:places_that_dont_exist/base/colors.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';
import 'package:places_that_dont_exist/ui/pages/adding_place.dart';
import 'package:places_that_dont_exist/ui/pages/place_details.dart';
import 'package:places_that_dont_exist/ui/pages/tips/tips_list.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';
import 'package:share_plus/share_plus.dart';

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
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      places = await DataStorage.getPlaces();
      filteredPlaces = List.from(places);

      setState(() {});
    });
  }

  Future<String> getFullPath(String relativePath) async {
    if (relativePath.isEmpty) {
      return ''; // Возвращаем пустую строку, если путь отсутствует
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$relativePath';
  }

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: theme?.bodySmall
                      ?.copyWith(fontSize: 17, color: AppColors.grey),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) {
                        return TipsListScreen(
                          title: "Tips for creating places",
                        );
                      }),
                    );
                  },
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return customTheme?.textRedGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ) ??
                          const LinearGradient(
                                  colors: [Colors.white, Colors.white])
                              .createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          );
                    },
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.white,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "?",
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                GestureDetector(
                  onTap: () async {
                    await Share.share("map");
                  },
                  child: Image.asset(AppImages.forward),
                )
              ],
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
        Positioned(
          top: 20.w,
          left: 10.w,
          right: 10.w, // Добавляем ограничение ширины
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    // Расширяем TextField на всю доступную ширину
                    child: SizedBox(
                      height: 52.w,
                      child: TextField(
                        style: theme.bodySmall?.copyWith(
                          color: AppColors.white,
                        ),
                        cursorColor: AppColors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.darkGrey,
                          suffixIcon:
                              Icon(Icons.search, color: AppColors.white),
                          hintText: "Search",
                          hintStyle: theme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) {
                          return AddingPlaceScreen(
                            title: "Adding a place",
                          );
                        }),
                      ).then((value) async {
                        // places = await DataStorage.getPlaces();
                        // filteredPlaces = List.from(places);
                        // print(places);
                        setState(() {});
                        FocusScope.of(context).unfocus();
                      });
                    },
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return customTheme?.secondaryGradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ) ??
                            const LinearGradient(
                                    colors: [Colors.white, Colors.white])
                                .createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            );
                      },
                      child: Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1, color: AppColors.white),
                        ),
                        child: Center(
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.white,
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "+",
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.w,
              ),
              Flexible(
                fit: FlexFit.loose,
                child: SizedBox(
                  height: 105.w,
                  child: ListView.builder(
                      itemCount: filteredPlaces.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) {
                                return PlaceDetailsScreen(
                                  title: filteredPlaces[index]['name'],
                                  data: filteredPlaces[index],
                                );
                              }),
                            );
                          },
                          child: placeCard(
                            theme: theme,
                            customTheme: customTheme,
                            imagePath: filteredPlaces[index]['image'],
                            title: filteredPlaces[index]['name'],
                            type: filteredPlaces[index]['type'],
                            colorType: filteredPlaces[index]['typeColor'],
                            hashtag: filteredPlaces[index]['tag'],
                            index: index,
                          ),
                        );
                      }),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget placeCard({
    required TextTheme theme,
    required customTheme,
    required String imagePath,
    required String title,
    required String type,
    required String colorType,
    required String hashtag,
    required int index,
  }) {
    return Container(
      width: 80.w,
      margin: EdgeInsets.only(right: 15.w),
      child: Column(
        children: [
          FutureBuilder<String>(
            future: getFullPath(imagePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 80.w,
                  height: 80.w,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  width: 80.w,
                  height: 80.w,
                  color: AppColors.grey,
                  child: Icon(Icons.image, color: AppColors.white),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(int.parse(colorType)), // Цвет рамки
                    width: 2.w, // Толщина рамки
                  ),
                  borderRadius: BorderRadius.circular(40.w), // Радиус рамки
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(40.w), // Радиус самого изображения
                  child: Image.file(
                    File(snapshot.data!),
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          SizedBox(
            height: 5.w,
          ),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: theme.bodySmall?.copyWith(fontSize: 12),
          )
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
