import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:places_that_dont_exist/base/colors.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/pages/adding_place.dart';
import 'package:places_that_dont_exist/ui/pages/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        gradient: customTheme?.gradientBackground,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Text(
                        'Places',
                        style: theme.titleLarge?.copyWith(fontSize: 58),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return customTheme?.textRedGradient.createShader(
                                Rect.fromLTWH(
                                    0, 0, bounds.width, bounds.height),
                              ) ??
                              const LinearGradient(
                                      colors: [Colors.white, Colors.white])
                                  .createShader(
                                Rect.fromLTWH(
                                    0, 0, bounds.width, bounds.height),
                              );
                        },
                        child: Text(
                          "That Don’t Exist",
                          style: theme.titleMedium,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    ShaderMask(
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
                                "?",
                                style: TextStyle(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) {
                            return SettingsScreen(
                              title: "Settings",
                            );
                          }),
                        );
                      },
                      child: Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.darkGrey,
                        ),
                        child: Image.asset(
                          AppImages.settingsMinimalistic,
                          width: 24.w,
                          height: 24.w,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            quoteOfTheDay(theme: theme, customTheme: customTheme),
            SizedBox(
              height: 10.w,
            ),
            placesBlock(theme: theme, customTheme: customTheme),
          ],
        ),
      ),
    );
  }

  Widget quoteOfTheDay({required TextTheme theme, required customTheme}) {
    return Container(
      width: double.infinity,
      height: 140.w,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quote of the day",
            style: theme.bodySmall?.copyWith(
              color: AppColors.grey,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.grey,
            ),
          ),
          SizedBox(
            height: 15.w,
          ),
          Row(
            children: [
              Image.asset(AppImages.star),
              SizedBox(
                width: 20.w,
              ),
              Expanded(
                child: Text(
                  '“Everything we can imagine is real.”',
                  maxLines: 2,
                  style: theme.titleMedium?.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 70),
                child: Image.asset(AppImages.forward),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Pablo Picasso',
                style: theme.bodySmall?.copyWith(color: AppColors.grey),
              ),
              SizedBox(
                width: 40.w,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget placesBlock({required TextTheme theme, required customTheme}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchField(theme: theme, customTheme: customTheme),
          SizedBox(height: 20.w),
          Row(
            children: [
              Image.asset(AppImages.pointOnMap),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "List of places",
                style: theme.bodySmall?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          Expanded(
            child: ListView(
              children: [
                placeCard(
                  imagePath: AppImages
                      .onboarding1, // Замените на правильный путь к изображению
                  title: "The Lost Island",
                  type: "Forest",
                  hashtag: "#LostWorld",
                ),
                SizedBox(height: 15.w),
                placeCard(
                  imagePath: AppImages
                      .onboarding2, // Замените на правильный путь к изображению
                  title: "Silent hill",
                  type: "City",
                  hashtag: "#MysteruWorld",
                ),
                SizedBox(height: 15.w),
                placeCard(
                  imagePath: AppImages
                      .onboarding3, // Замените на правильный путь к изображению
                  title: "Salty lake",
                  type: "Lake",
                  hashtag: "#Dreamplace",
                ),
              ],
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
                  onTap: () {
                    // Здесь можно добавить функционал для обновления данных
                  },
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
            );
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
    required String imagePath,
    required String title,
    required String type,
    required String hashtag,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              width: 100.w,
              height: 100.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      ),
                ),
                SizedBox(height: 5.w),
                Text(
                  type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
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
          Icon(
            Icons.more_vert,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }
}
