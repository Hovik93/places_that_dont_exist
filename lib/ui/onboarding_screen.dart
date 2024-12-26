import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:places_that_dont_exist/base/colors.dart';
import 'package:places_that_dont_exist/base/constants.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _onBoardingData = [
    {
      'isView': true,
      'image': AppImages.onboarding1,
      'title': "Create Your Own Places",
      'description':
          "Design captivating cities, quaint villages, stunning landscapes, and more!"
    },
    {
      'isView': false,
      'image': AppImages.onboarding2,
      'title': "Inspiring Quotes & Tips",
      'description':
          "Stay motivated with a collection of inspiring quotes about creativity and imagination.",
    },
    {
      'isView': false,
      'image': AppImages.onboarding3,
      'title': "Visualize Your Ideas",
      'description':
          "Enhance your creations with images and sketches. Bring your locations to life visually"
    },
  ];

  void _nextPage() async {
    if (_currentIndex < _onBoardingData.length - 1) {
      setState(() {
        _currentIndex++;
        _onBoardingData[_currentIndex]['isView'] = true;
      });
    } else {
      await DataStorage.setOnboardingSeen();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _skipOnboarding() async {
    await DataStorage.setOnboardingSeen();
    Navigator.pushReplacementNamed(context, '/home');
  }

  _launchURL({required String urlLink}) async {
    final Uri url = Uri.parse(urlLink);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final customTheme = Theme.of(context).extension<CustomTheme>();
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: BoxDecoration(
          gradient: customTheme?.gradientBackground,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 10.w,
              ),
              SizedBox(
                height: 6.w,
                child: ListView.builder(
                  itemCount: _onBoardingData.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return _onBoardingData[index]['isView']
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
                                AppColors.darkBlack,
                                AppColors.darkBlack
                              ]).createShader(
                                Rect.fromLTWH(
                                    0, 0, bounds.width, bounds.height),
                              );
                      },
                      child: Container(
                        height: 6.w,
                        width: 113.w,
                        margin: EdgeInsets.only(right: 2.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.w),
                    Expanded(
                      child: Image.asset(
                        _onBoardingData[_currentIndex]['image']!,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 30.w),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.darkGrey,
                ),
                child: Column(
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
                        _onBoardingData[_currentIndex]['title']!,
                        style: theme.headlineLarge?.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.w),
                    Text(
                      _onBoardingData[_currentIndex]['description']!,
                      style: theme.titleSmall?.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.w,
              ),
              SizedBox(
                height: 50.w,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentIndex != _onBoardingData.length - 1)
                      Expanded(
                        child: GestureDetector(
                          onTap: _skipOnboarding,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return customTheme?.secondaryGradient
                                      .createShader(
                                    Rect.fromLTWH(
                                        0, 0, bounds.width, bounds.height),
                                  ) ??
                                  LinearGradient(colors: [
                                    AppColors.white,
                                    AppColors.white
                                  ]).createShader(
                                    Rect.fromLTWH(
                                        0, 0, bounds.width, bounds.height),
                                  );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.bg,
                                border: Border.all(
                                    width: 1, color: AppColors.white),
                              ),
                              child: Center(
                                child: Text(
                                  "Skip",
                                  style: theme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_currentIndex != _onBoardingData.length - 1)
                      SizedBox(
                        width: 20.w,
                      ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: customTheme?.secondaryGradient,
                          ),
                          child: Center(
                            child: Text(
                              _currentIndex == _onBoardingData.length - 1
                                  ? "Continue"
                                  : "Next",
                              style: theme.titleMedium?.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 10.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          _launchURL(urlLink: userAgreementUrl);
                        },
                        child: Text(
                          'Terms of use',
                          style: theme.bodySmall?.copyWith(
                            fontSize: 8.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          "|",
                          style: TextStyle(
                            color: AppColors.gradientTextRed1,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _launchURL(urlLink: privacyPolicyUrl);
                        },
                        child: Text(
                          'Privacy policy',
                          style: theme.bodySmall
                              ?.copyWith(fontSize: 8.sp, color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.w),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
