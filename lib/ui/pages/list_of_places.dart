// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';
import 'package:places_that_dont_exist/ui/pages/adding_place.dart';
import 'package:places_that_dont_exist/ui/pages/map.dart';
import 'package:places_that_dont_exist/ui/pages/tips/tips_list.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';

import 'package:places_that_dont_exist/base/colors.dart';

// ignore: must_be_immutable
class ListOfPlaceScreen extends StatefulWidget {
  String? title;
  ListOfPlaceScreen({
    super.key,
    this.title,
  });

  @override
  State<ListOfPlaceScreen> createState() => _ListOfPlaceScreenState();
}

class _ListOfPlaceScreenState extends State<ListOfPlaceScreen> {
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

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredPlaces = places
          .where((place) => place['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.darkGrey,
      builder: (context) {
        final TextTheme theme = Theme.of(context).textTheme;
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Sort",
                style: theme.bodySmall?.copyWith(
                  color: AppColors.grey,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 15.w),
              Divider(color: AppColors.black, thickness: 1),
              InkWell(
                onTap: () {
                  setState(() {
                    filteredPlaces.sort((a, b) {
                      return b['date'].compareTo(
                          a['date']); // Сортировка по дате (новые сначала)
                    });
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  height: 60.w,
                  child: Center(
                    child: Text(
                      "New ones first",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                  ),
                ),
              ),
              Divider(color: AppColors.black, thickness: 1),
              InkWell(
                onTap: () {
                  setState(() {
                    filteredPlaces.sort((a, b) {
                      return a['date'].compareTo(
                          b['date']); // Сортировка по дате (старые сначала)
                    });
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  height: 60.w,
                  child: Center(
                    child: Text(
                      "The old ones first",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.w),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.gradientTextRed1,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: theme.bodySmall?.copyWith(fontSize: 18.sp),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.w),
            ],
          ),
        );
      },
    );
  }

  void deletePlace(int index) async {
    setState(() {
      filteredPlaces
          .removeAt(index); // Удаляем место из отфильтрованного списка
      places = List.from(filteredPlaces); // Обновляем исходный список
    });

    // Сохраняем обновленный список
    await DataStorage.savePlaces(places);
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Снимает фокус с любого TextField
      },
      child: Scaffold(
        body: body(theme: theme, customTheme: customTheme),
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
            Expanded(child: placesBlock(theme: theme, customTheme: customTheme))
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) {
                        return MapPage(
                          title: "Map",
                        );
                      }),
                    );
                  },
                  child: Image.asset(AppImages.pointOnMap),
                )
              ],
            ),
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
          SizedBox(height: 20.w),
          searchField(theme: theme, customTheme: customTheme),
          SizedBox(height: 20.w),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlaces.length,
              itemBuilder: (context, index) {
                return placeCard(
                  theme: theme,
                  customTheme: customTheme,
                  imagePath: filteredPlaces[index]['image'],
                  title: filteredPlaces[index]['name'],
                  type: filteredPlaces[index]['type'],
                  colorType: filteredPlaces[index]['typeColor'],
                  hashtag: filteredPlaces[index]['tag'],
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget searchField({required TextTheme theme, required customTheme}) {
    return Row(
      children: [
        Flexible(
          child: Container(
            width: double.infinity,
            height: 48.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.darkGrey,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.white,
                    ),
                    onChanged: updateSearch,
                    cursorColor: AppColors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkGrey,
                      suffixIcon: Icon(Icons.search, color: AppColors.white),
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.w),
                  child: VerticalDivider(
                    width: 1,
                    color: AppColors.grey.withOpacity(0.5),
                  ),
                ),
                GestureDetector(
                  onTap: showSortOptions,
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.swap_vert_circle_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
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
              places = await DataStorage.getPlaces();
              filteredPlaces = List.from(places);
              print(places);
              setState(() {});
              FocusScope.of(context).unfocus();
            });
          },
          child: ShaderMask(
            shaderCallback: (bounds) {
              return customTheme?.secondaryGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ) ??
                  const LinearGradient(colors: [Colors.white, Colors.white])
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
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
      height: 110.w,
      margin: EdgeInsets.only(bottom: 15.w),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: getFullPath(imagePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 90.w,
                  height: 110.w,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  width: 90.w,
                  height: 110.w,
                  color: AppColors.grey,
                  child: Icon(Icons.image, color: AppColors.white),
                );
              }
              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                child: Image.file(
                  File(snapshot.data!),
                  width: 90.w,
                  height: 110.w,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          // SizedBox(width: 15.w),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    type,
                    style: theme.bodySmall?.copyWith(
                      color: Color(int.parse(colorType)),
                    ),
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    hashtag,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10.w, top: 10.w),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible:
                      true, // Позволяет закрывать диалог при нажатии вне него
                  builder: (context) {
                    final theme = Theme.of(context).textTheme;

                    return Dialog(
                      backgroundColor: Colors.transparent, // Прозрачный фон
                      insetPadding: EdgeInsets.zero, // Убираем отступы
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(
                              context); // Закрывает диалог при нажатии за пределами
                        },
                        child: Container(
                          color:
                              Colors.transparent, // Прозрачный фон для области
                          child: Center(
                            child: GestureDetector(
                              onTap:
                                  () {}, // Блокирует закрытие при нажатии внутри
                              child: Container(
                                width: 105.w, // Фиксированная ширина окна
                                decoration: BoxDecoration(
                                  color: AppColors.darkGrey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            FocusScope.of(context).unfocus();
                                          },
                                          child: Text(
                                            'Edit',
                                            style: theme.bodySmall,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10.w,
                                          ),
                                          child: Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            FocusScope.of(context).unfocus();
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.darkGrey,
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'Delete',
                                                        style: theme.titleMedium
                                                            ?.copyWith(
                                                          color: AppColors
                                                              .gradientTextRed1,
                                                          fontSize: 22.w,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        'Do you really want to delete the place?',
                                                        style: theme.bodySmall,
                                                      ),
                                                      SizedBox(height: 20),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context); // Закрыть диалог
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                              },
                                                              child: ShaderMask(
                                                                shaderCallback:
                                                                    (bounds) {
                                                                  return customTheme
                                                                          ?.secondaryGradient
                                                                          .createShader(
                                                                        Rect.fromLTWH(
                                                                            0,
                                                                            0,
                                                                            bounds.width,
                                                                            bounds.height),
                                                                      ) ??
                                                                      LinearGradient(
                                                                          colors: [
                                                                            AppColors.white,
                                                                            AppColors.white
                                                                          ]).createShader(
                                                                        Rect.fromLTWH(
                                                                            0,
                                                                            0,
                                                                            bounds.width,
                                                                            bounds.height),
                                                                      );
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      width: 1,
                                                                      color: AppColors
                                                                          .white,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                        'Cancel',
                                                                        style: theme
                                                                            .bodySmall),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                deletePlace(
                                                                    index);
                                                                Navigator.pop(
                                                                    context); // Закрыть диалог
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColors
                                                                      .gradientTextRed1,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    'Delete',
                                                                    style: theme
                                                                        .bodySmall
                                                                        ?.copyWith(
                                                                      color: AppColors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Text(
                                            'Delete',
                                            style: theme.bodySmall?.copyWith(
                                              color: AppColors.gradientTextRed1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
                // showDialog(
                //   context: context,
                //   builder: (context) {
                //     return AlertDialog(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //       backgroundColor: AppColors.darkGrey,
                //       content: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Text(
                //             'Delete',
                //             style: theme.titleMedium?.copyWith(
                //               color: AppColors.gradientTextRed1,
                //               fontSize: 22.w,
                //             ),
                //           ),
                //           SizedBox(height: 10),
                //           Text(
                //             'Do you really want to delete the data?',
                //             style: theme.bodySmall,
                //           ),
                //           SizedBox(height: 20),
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Expanded(
                //                 child: GestureDetector(
                //                   onTap: () {
                //                     Navigator.pop(context); // Закрыть диалог
                //                   },
                //                   child: ShaderMask(
                //                     shaderCallback: (bounds) {
                //                       return customTheme?.secondaryGradient
                //                               .createShader(
                //                             Rect.fromLTWH(0, 0, bounds.width,
                //                                 bounds.height),
                //                           ) ??
                //                           LinearGradient(colors: [
                //                             AppColors.white,
                //                             AppColors.white
                //                           ]).createShader(
                //                             Rect.fromLTWH(0, 0, bounds.width,
                //                                 bounds.height),
                //                           );
                //                     },
                //                     child: Container(
                //                       padding:
                //                           EdgeInsets.symmetric(vertical: 10),
                //                       decoration: BoxDecoration(
                //                         border: Border.all(
                //                           width: 1,
                //                           color: AppColors.white,
                //                         ),
                //                         borderRadius: BorderRadius.circular(20),
                //                       ),
                //                       child: Center(
                //                         child: Text('Cancel',
                //                             style: theme.bodySmall),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(width: 10),
                //               Expanded(
                //                 child: GestureDetector(
                //                   onTap: () {
                //                     // Логика удаления данных
                //                     Navigator.pop(context); // Закрыть диалог
                //                   },
                //                   child: Container(
                //                     padding: EdgeInsets.symmetric(vertical: 10),
                //                     decoration: BoxDecoration(
                //                       color: AppColors.gradientTextRed1,
                //                       borderRadius: BorderRadius.circular(20),
                //                     ),
                //                     child: Center(
                //                       child: Text(
                //                         'Delete',
                //                         style: theme.bodySmall?.copyWith(
                //                           color: AppColors.white,
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // );
              },
              child: Image.asset(AppImages.dotHoriz),
            ),
          ),
        ],
      ),
    );
  }
}
