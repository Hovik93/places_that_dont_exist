// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';
import 'package:places_that_dont_exist/ui/home.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:places_that_dont_exist/base/colors.dart';
import 'package:places_that_dont_exist/base/constants.dart';
import 'package:places_that_dont_exist/base/images.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatefulWidget {
  String? title;
  SettingsScreen({
    super.key,
    this.title,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final InAppReview inAppReview = InAppReview.instance;

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
      body: body(theme: theme, customTheme: customTheme),
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
              padding: EdgeInsets.only(top: 10.w, bottom: 30.w),
              child: appBar(theme: theme),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      _launchURL(urlLink: privacyPolicyUrl);
                    },
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Privacy policy",
                            style: theme.bodySmall,
                          ),
                          Image.asset(
                            AppImages.privacySecurity,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.w),
                    child: InkWell(
                      onTap: () {
                        _launchURL(urlLink: userAgreementUrl);
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "User Agreement ",
                              style: theme.bodySmall,
                            ),
                            Image.asset(
                              AppImages.userAgreement,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await inAppReview.isAvailable()) {
                        inAppReview.requestReview();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Leave Feedback",
                            style: theme.bodySmall,
                          ),
                          Image.asset(
                            AppImages.leaveFeedback,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: AppColors.darkGrey,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Delete',
                                  style: theme.titleMedium?.copyWith(
                                    color: AppColors.gradientTextRed1,
                                    fontSize: 22.w,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Do you really want to delete the date?',
                                  style: theme.bodySmall,
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: ShaderMask(
                                          shaderCallback: (bounds) {
                                            return customTheme
                                                    ?.secondaryGradient
                                                    .createShader(
                                                  Rect.fromLTWH(
                                                      0,
                                                      0,
                                                      bounds.width,
                                                      bounds.height),
                                                ) ??
                                                LinearGradient(colors: [
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
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: AppColors.white,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Text('Cancel',
                                                  style: theme.bodySmall),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          await DataStorage
                                              .clearAllData(); // Удаляем все данные
                                          Navigator.pop(
                                              context); // Закрываем диалог
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage()), // Переход на HomePage
                                            (route) =>
                                                false, // Удаляем все предыдущие маршруты из стека
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.gradientTextRed1,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Delete',
                                              style: theme.bodySmall?.copyWith(
                                                color: AppColors.white,
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
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Delete data",
                            style: theme.bodySmall,
                          ),
                          Image.asset(
                            AppImages.trash,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget appBar({required TextTheme? theme}) {
    return BottomBorderContainer(
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 26.w, bottom: 15),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey),
            ),
            const SizedBox(width: 10),
            Text(
              'Settings',
              style: theme?.bodySmall
                  ?.copyWith(fontSize: 17, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
