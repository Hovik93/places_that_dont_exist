// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';

import 'package:places_that_dont_exist/base/colors.dart';

// ignore: must_be_immutable
class PlaceDetailsScreen extends StatefulWidget {
  String? title;
  Map<String, dynamic>? data;
  PlaceDetailsScreen({
    super.key,
    this.title,
    this.data,
  });

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> filteredPlaces = [];
  String searchQuery = '';
  bool isAscending = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      places = await DataStorage.getPlaces();
      filteredPlaces = List.from(places);
      setState(() {});
      print(places);
    });

    super.initState();
  }

  Future<String> getFullPath(String relativePath) async {
    if (relativePath.isEmpty) {
      return ''; // Возвращаем пустую строку, если путь отсутствует
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$relativePath';
  }

  Future<File?> loadImage(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return null;
    }
    final fullPath = await getFullPath(relativePath);
    final file = File(fullPath);

    if (await file.exists()) {
      return file;
    } else {
      print("Файл не найден: $fullPath");
      return null;
    }
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
              child: SingleChildScrollView(
                child: placesBlock(theme: theme, customTheme: customTheme),
              ),
            )
            // bodyContent(theme: theme, customTheme: customTheme),
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
                  style: theme?.bodySmall
                      ?.copyWith(fontSize: 17, color: AppColors.grey),
                ),
              ],
            ),
            Image.asset(AppImages.pointOnMap),
          ],
        ),
      ),
    );
  }

  Widget placesBlock({required TextTheme theme, required customTheme}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.w,
          ),
          Stack(
            children: [
              FutureBuilder<String>(
                future: getFullPath(widget.data?['image']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: double.infinity,
                      height: 200.w,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      width: double.infinity,
                      height: 200.w,
                      color: AppColors.grey,
                      child: Icon(Icons.image, color: AppColors.white),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(snapshot.data!),
                      width: double.infinity,
                      height: 200.w,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              Positioned(
                right: 10.w,
                bottom: 10.w,
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    AppImages.camera,
                    width: 30.w,
                    height: 24.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.w,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.darkGrey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data?['name'],
                  style: theme.bodySmall,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Type of Place",
                        style: theme.bodySmall
                            ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
                      ),
                      Text(
                        widget.data?['type'],
                        style: theme.bodySmall?.copyWith(
                            color: Color(int.parse(widget.data?['typeColor']))),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tag",
                      style: theme.bodySmall
                          ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
                    ),
                    Text(
                      widget.data?['tag'],
                      style: theme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.w,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.w),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: theme.bodySmall
                            ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
                      ),
                      SizedBox(
                        height: 10.w,
                      ),
                      Text(
                        widget.data?['description'],
                        style: theme.bodySmall,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20.w,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.darkGrey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Geographical Characteristics",
                  style: theme.bodySmall
                      ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.w),
                  child: Text(
                    widget.data?['geographical'],
                    style: theme.bodySmall,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        "Area",
                        style: theme.bodySmall?.copyWith(color: AppColors.grey),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.data?['geographicalCharacteristics']['area'],
                        style: theme.bodySmall,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 60.w,
                        child: Text(
                          "Climate",
                          style:
                              theme.bodySmall?.copyWith(color: AppColors.grey),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          widget.data?['geographicalCharacteristics']
                              ['climate'],
                          style: theme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        "Terrain",
                        style: theme.bodySmall?.copyWith(color: AppColors.grey),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.data?['geographicalCharacteristics']['terrain'],
                        style: theme.bodySmall,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
