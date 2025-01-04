// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
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
    {"type": "City", "color": ""},
    {"type": "Desert", "color": ""},
    {"type": "Mountain", "color": ""},
    {"type": "Lake", "color": ""},
    {"type": "Village", "color": ""},
    {"type": "Forest", "color": ""},
  ];
  String selectedOption = '';
  TextEditingController controller = TextEditingController();
  TextEditingController tagController = TextEditingController();

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
                          controller.clear();
                        });
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
                                  controller.clear();
                                });
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
                ),
                SizedBox(height: 10.w),
                buildCharacteristicSection(
                  title: "Climate",
                  hintText: "Enter climate",
                  theme: theme,
                ),
                SizedBox(height: 10.w),
                buildCharacteristicSection(
                  title: "Terrain",
                  hintText: "Enter terrain",
                  theme: theme,
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
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme?.bodySmall?.copyWith(
            fontSize: 12.sp,
            color: AppColors.grey,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: TextField(
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
    bool allFieldsFilled = selectedOption.isNotEmpty &&
        (selectedOption != "Enter other" || controller.text.isNotEmpty) &&
        tagController.text.isNotEmpty &&
        isMainTextFieldFilled;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
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
            onTap: () {
              Navigator.pop(context);
            },
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
