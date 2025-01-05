// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';

import 'package:places_that_dont_exist/base/colors.dart';

// ignore: must_be_immutable
class AddingPlaceScreen extends StatefulWidget {
  String? title;
  AddingPlaceScreen({
    super.key,
    this.title,
  });

  @override
  State<AddingPlaceScreen> createState() => _AddingPlaceScreenState();
}

class _AddingPlaceScreenState extends State<AddingPlaceScreen> {
  File? _image; // Для хранения выбранного изображения
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> options = [
    {"type": "City", "color": "0xffFEE21D"},
    {"type": "Desert", "color": "0xffF05634"},
    {"type": "Mountain", "color": "0xff5F54F5"},
    {"type": "Lake", "color": "0xff54D7F5"},
    {"type": "Village", "color": "0xff5CF554"},
    {"type": "Forest", "color": "0xff7AE09F"},
  ];
  String selectedOption = '';
  String enterOther = '';
  String typeColor = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController controller = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController climateController = TextEditingController();
  TextEditingController terrainController = TextEditingController();

  bool isMainTextFieldFilled = false;

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  // Выбор изображения
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800, // Уменьшение ширины изображения
        maxHeight: 800, // Уменьшение высоты изображения
        imageQuality: 85, // Сжатие в процентах
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error while selecting image: $e");
    }
  }

  Future<String> saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory('${directory.path}/place_images');

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final fileName = image.uri.pathSegments.last;
    final savedImagePath = '${imageDirectory.path}/$fileName';

    await image.copy(savedImagePath);
    return 'place_images/$fileName'; // Возвращаем относительный путь
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
                child: bodyContent(theme: theme, customTheme: customTheme),
              ),
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
                  'Adding a place',
                  style: theme?.bodySmall
                      ?.copyWith(fontSize: 17, color: AppColors.grey),
                ),
              ],
            ),
            ShaderMask(
              shaderCallback: (bounds) {
                return customTheme?.textRedGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ) ??
                    const LinearGradient(colors: [Colors.white, Colors.white])
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
          ],
        ),
      ),
    );
  }

  Widget bodyContent({required TextTheme? theme, required customTheme}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(
            height: 30.w,
          ),
          _image != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        _image!,
                        width: double.infinity,
                        height: 200.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 10.w,
                      bottom: 10.w,
                      child: GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                        },
                        child: Image.asset(
                          AppImages.camera,
                          width: 30.w,
                          height: 24.w,
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 200.w,
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(AppImages.camera),
                          SizedBox(
                            height: 10.w,
                          ),
                          Text(
                            "Upload Image",
                            style: theme?.bodySmall?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 15.w,
          ),
          placeNameBlock(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 15.w,
          ),
          placeTypeBlock(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 15.w,
          ),
          tagBlock(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 15.w,
          ),
          descriptionBlock(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 15.w,
          ),
          geographicalCharacteristics(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 15.w,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            child: Divider(
              thickness: 0.3,
              height: 0.3,
              color: AppColors.grey,
            ),
          ),
          SizedBox(
            height: 15.w,
          ),
          buttonsBlock(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 20.w,
          )
        ],
      ),
    );
  }

  Widget placeNameBlock({required TextTheme? theme, required customTheme}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.darkGrey,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "2",
                style: theme?.bodySmall
                    ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "Place Name",
                style: theme?.bodySmall?.copyWith(fontSize: 12.sp),
              )
            ],
          ),
          SizedBox(height: 10.w),
          TextField(
            style: theme?.bodySmall?.copyWith(
              color: AppColors.white,
            ),
            controller: nameController,
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: "Enters the name of his fictional place",
              hintStyle: theme?.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget placeTypeBlock({required TextTheme? theme, required customTheme}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.darkGrey,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "3",
                style: theme?.bodySmall
                    ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "Type of Place",
                style: theme?.bodySmall?.copyWith(fontSize: 12.sp),
              )
            ],
          ),
          SizedBox(height: 10.w),
          Wrap(
            spacing: 20.w,
            children: [
              ...options
                  .map(
                    (option) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOption = option["type"];
                          typeColor = option["color"];
                          controller.clear();
                        });
                        print(typeColor);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return selectedOption == option["type"]
                                  ? customTheme?.secondaryGradient.createShader(
                                        Rect.fromLTWH(
                                            0, 0, bounds.width, bounds.height),
                                      ) ??
                                      LinearGradient(colors: [
                                        AppColors.white,
                                        AppColors.white
                                      ]).createShader(
                                        Rect.fromLTWH(
                                            0, 0, bounds.width, bounds.height),
                                      )
                                  : LinearGradient(colors: [
                                      AppColors.white,
                                      AppColors.white
                                    ]).createShader(
                                      Rect.fromLTWH(
                                          0, 0, bounds.width, bounds.height),
                                    );
                            },
                            child: Radio<String>(
                              value: option["type"],
                              groupValue: selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value!;
                                  typeColor = option["color"];
                                  controller.clear();
                                });
                                print(typeColor);
                              },
                              activeColor: Colors.white, // Замените на градиент
                            ),
                          ),
                          Text(
                            option["type"],
                            style: theme?.bodySmall?.copyWith(
                                color: selectedOption == option["type"]
                                    ? AppColors.white
                                    : AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return customTheme?.secondaryGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ) ??
                          LinearGradient(
                                  colors: [AppColors.white, AppColors.white])
                              .createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          );
                    },
                    child: Radio<String>(
                      value: "Enter other",
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value!;
                          typeColor = "0xffDE2D95";
                          print(typeColor);
                        });
                      },
                      activeColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Enter other",
                        hintStyle:
                            theme?.bodySmall?.copyWith(color: AppColors.grey),
                        border: InputBorder.none,
                      ),
                      onTap: () {
                        setState(() {
                          selectedOption = "Enter other";
                        });
                      },
                      onChanged: (text) {
                        if (text.isNotEmpty) {
                          setState(() {
                            selectedOption = "Enter other";
                            enterOther = text;
                          });
                        }
                      },
                      style: theme?.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tagBlock({required TextTheme? theme, required customTheme}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.darkGrey,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "4",
                style: theme?.bodySmall
                    ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "Tag",
                style: theme?.bodySmall?.copyWith(fontSize: 12.sp),
              )
            ],
          ),
          SizedBox(height: 10.w),
          TextField(
            controller: tagController,
            style: theme?.bodySmall?.copyWith(color: AppColors.white),
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: "A tag for combining places",
              hintStyle: theme?.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
              border: InputBorder.none,
            ),
            onChanged: (text) {
              if (text.isEmpty) {
                // Если поле пустое, ничего не добавляем
                return;
              }
              if (!text.startsWith("#")) {
                // Если текст не начинается с #, добавляем #
                tagController.value = TextEditingValue(
                  text: "#$text",
                  selection: TextSelection.collapsed(offset: text.length + 1),
                );
              }
            },
            onSubmitted: (text) {
              if (text == "#") {
                // Если поле содержит только #, очищаем поле
                tagController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget descriptionBlock({required TextTheme? theme, required customTheme}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.darkGrey,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "5",
                style: theme?.bodySmall
                    ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "Description",
                style: theme?.bodySmall?.copyWith(fontSize: 12.sp),
              )
            ],
          ),
          SizedBox(height: 10.w),
          TextField(
            maxLines: null,
            controller: descriptionController,
            style: theme?.bodySmall?.copyWith(
              color: AppColors.white,
              height: 1.5, // Высота строки
            ),
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText:
                  "Describe the features of your place, its history, culture and atmosphere",
              hintStyle: theme?.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget geographicalCharacteristics(
      {required TextTheme? theme, required customTheme}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.darkGrey,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "6",
                style: theme?.bodySmall
                    ?.copyWith(fontSize: 12.sp, color: AppColors.grey),
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "Geographical Characteristics",
                style: theme?.bodySmall?.copyWith(fontSize: 12.sp),
              )
            ],
          ),
          SizedBox(height: 10.w),
          TextField(
            maxLines: null,
            style: theme?.bodySmall?.copyWith(
              color: AppColors.white,
              height: 1.5, // Высота строки
            ),
            onChanged: (text) {
              setState(() {
                isMainTextFieldFilled = text.isNotEmpty;
              });
            },
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText:
                  "Enter information about the geographical characteristics of the place",
              hintStyle: theme?.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: !isMainTextFieldFilled ? 20.w : 10.w),

          // Дополнительные секции
          if (isMainTextFieldFilled)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCharacteristicSection(
                  title: "Area",
                  hintText: "Enter area",
                  theme: theme,
                  controller: areaController,
                ),
                SizedBox(height: 10.w),
                buildCharacteristicSection(
                  title: "Climate",
                  hintText: "Enter climate",
                  theme: theme,
                  controller: climateController,
                ),
                SizedBox(height: 10.w),
                buildCharacteristicSection(
                  title: "Terrain",
                  hintText: "Enter terrain",
                  theme: theme,
                  controller: terrainController,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Area",
                  style: theme?.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  "Climate",
                  style: theme?.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  "Terrain",
                  style: theme?.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildCharacteristicSection({
    required String title,
    required String hintText,
    required TextTheme? theme,
    required TextEditingController controller,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50.w,
          child: Text(
            title,
            style: theme?.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: AppColors.grey,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 3,
            minLines: 1,
            style: theme?.bodySmall?.copyWith(
              color: AppColors.white,
              height: 1.5,
            ),
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hintText,
              hintStyle: theme?.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buttonsBlock({required TextTheme? theme, required customTheme}) {
    bool allFieldsFilled = nameController.text.isNotEmpty &&
        selectedOption.isNotEmpty &&
        (selectedOption != "Enter other" || controller.text.isNotEmpty) &&
        tagController.text.isNotEmpty &&
        isMainTextFieldFilled;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
            child: ShaderMask(
              shaderCallback: (bounds) {
                return customTheme?.secondaryGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ) ??
                    LinearGradient(colors: [AppColors.white, AppColors.white])
                        .createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.white,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text('Cancel', style: theme?.bodySmall),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: GestureDetector(
            onTap: allFieldsFilled
                ? () async {
                    Map<String, dynamic> placeData = {};
                    String? relativePath;

                    try {
                      relativePath = await saveImage(_image!);
                      try {
                        // Получаем директорию документов
                        final directory =
                            await getApplicationDocumentsDirectory();

                        // Создаём папку, если она не существует
                        final imageDirectory =
                            Directory('${directory.path}/subcategory_images');
                        if (!await imageDirectory.exists()) {
                          await imageDirectory.create(recursive: true);
                        }
                      } catch (e) {
                        print("Ошибка при сохранении изображения: $e");
                      }

                      // Формируем объект с данными
                      placeData = {
                        'image': relativePath,
                        'name': nameController.text,
                        "type": selectedOption == "Enter other"
                            ? enterOther
                            : selectedOption,
                        'typeColor': typeColor,
                        'tag': tagController.text,
                        'description': descriptionController.text,
                        'geographicalCharacteristics': {
                          'area': areaController.text,
                          'climate': climateController.text,
                          'terrain': terrainController.text,
                        },
                        'date': DateTime.now().toIso8601String(),
                      };

                      // Получаем текущие данные и добавляем новый объект
                      final List<Map<String, dynamic>> places =
                          await DataStorage.getPlaces();
                      places.add(placeData);

                      // Сохраняем обновленный список
                      await DataStorage.savePlaces(places);
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    } catch (e) {
                      print("Ошибка при сохранении данных: $e");
                    }
                  }
                : null,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return allFieldsFilled
                    ? customTheme?.secondaryGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ) ??
                        LinearGradient(
                                colors: [AppColors.white, AppColors.white])
                            .createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        )
                    : LinearGradient(colors: [AppColors.white, AppColors.white])
                        .createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color:
                        allFieldsFilled ? AppColors.white : AppColors.darkBlack,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 1, color: AppColors.grey)),
                child: Center(
                  child: Text(
                    'Save',
                    style: theme?.bodySmall?.copyWith(
                      color: AppColors.grey,
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
}
