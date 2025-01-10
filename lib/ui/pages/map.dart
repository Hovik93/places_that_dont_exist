// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
// import 'dart:ui';

import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:cross_file/cross_file.dart';

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
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> filteredPlaces = [];
  double _currentScale = 1.0;
  final Random _random = Random();

  final Map<String, String> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<String> _getOrCacheImagePath(String imagePath) async {
    if (_imageCache.containsKey(imagePath)) {
      return _imageCache[imagePath]!;
    }
    final path = await getFullPath(imagePath);
    _imageCache[imagePath] = path;
    return path;
  }

  Future<void> _loadData() async {
    places = await DataStorage.getPlaces();

    bool isWithinMapBounds(double lat, double lon) {
      return lat >= -60 && lat <= 0 && lon >= -170 && lon <= 170;
    }

    for (var place in places) {
      do {
        place['latitude'] = _random.nextDouble() * 60 - 60;
        place['longitude'] = _random.nextDouble() * 340 - 170;
      } while (!isWithinMapBounds(place['latitude'], place['longitude']));
    }

    filteredPlaces = List.from(places);

    setState(() {});
  }

  Future<String> getFullPath(String relativePath) async {
    if (relativePath.isEmpty) {
      return '';
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$relativePath';
  }

  void _filterPlaces(String query) {
    setState(() {
      filteredPlaces = places
          .where((place) =>
              place['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _captureAndShareScreenshot() async {
    try {
      // Получаем RenderRepaintBoundary
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Захватываем изображение
      var image = await boundary.toImage(pixelRatio: 3.0);

      // Преобразуем в ByteData
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        // Конвертируем в Uint8List
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Сохраняем изображение во временную директорию
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/screenshot.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        // Конвертируем в XFile для `shareXFiles`
        final xFile = XFile(filePath);

        // Шарим изображение
        await Share.shareXFiles(
          [xFile],
          text: 'Check out this map!',
        );
      }
    } catch (e) {
      debugPrint('Error capturing screenshot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final customTheme = Theme.of(context).extension<CustomTheme>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: Scaffold(
          body: body(theme: theme, customTheme: customTheme),
        ),
      ),
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
                  onTap: _captureAndShareScreenshot,
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
            constrained: true,
            boundaryMargin: EdgeInsets.all(0),
            maxScale: 7.0,
            minScale: 1.0,
            onInteractionUpdate: (ScaleUpdateDetails details) {
              if (details.scale != 1.0) {
                setState(() {
                  _currentScale = details.scale;
                });
              }
            },
            child: SimpleMap(
              instructions: SMapWorld.instructionsMercator,
              defaultColor: Colors.grey,
              countryBorder: CountryBorder(color: Colors.green),
              colors: SMapWorldColors().toMap(),
              callback: (id, name, details) {
                debugPrint('Tapped on country: $name ($id)');
              },
              markers: [
                ...filteredPlaces.map((place) {
                  if (!_isValidCoordinates(
                      place['latitude'], place['longitude'])) {
                    return null;
                  }
                  return SimpleMapMarker(
                    markerSize: Size(30, 30),
                    latLong: LatLong(
                      latitude: place['latitude'],
                      longitude: place['longitude'],
                    ),
                    marker: _buildMarker(place, _currentScale),
                  );
                }).whereType<SimpleMapMarker>(),
              ],
            ),
          ),
        ),
        Positioned(
          top: 20.w,
          left: 10.w,
          right: 10.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52.w,
                      child: TextField(
                        onChanged: (value) {
                          _filterPlaces(value);
                        },
                        style: theme.bodySmall?.copyWith(
                          color: AppColors.white,
                        ),
                        cursorColor: AppColors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.darkGrey,
                          suffixIcon: Image.asset(AppImages.search),
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
                        _loadData();
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
                          color: AppColors.darkBlack,
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
          _imageCache.containsKey(imagePath)
              ? _buildCachedImage(_imageCache[imagePath]!, colorType)
              : FutureBuilder<String>(
                  future: _getOrCacheImagePath(imagePath),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildPlaceholder();
                    }
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return _buildCachedImage(snapshot.data!, colorType);
                    }
                    return _buildErrorPlaceholder();
                  },
                ),
          SizedBox(height: 5.w),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: theme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCachedImage(String path, String colorType) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(int.parse(colorType)),
          width: 2.w,
        ),
        borderRadius: BorderRadius.circular(40.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.w),
        child: Image.file(
          File(path),
          width: 80.w,
          height: 80.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80.w,
      height: 80.w,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 80.w,
      height: 80.w,
      color: AppColors.grey,
      child: Icon(Icons.image, color: AppColors.white),
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

  Widget _buildMarker(Map<String, dynamic> place, double scale) {
    if (scale < 1.7) {
      return Image.asset(AppImages.marker);
    } else {
      return FutureBuilder<String>(
        future: getFullPath(place['image']),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            );
          }
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(int.parse(place['typeColor'])),
                width: 2,
              ),
              image: DecorationImage(
                image: FileImage(File(snapshot.data!)),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      );
    }
  }

  bool _isValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (!latitude.isFinite || !longitude.isFinite) return false;
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180)
      return false;
    return true;
  }
}
