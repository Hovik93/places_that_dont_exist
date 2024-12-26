import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:places_that_dont_exist/base/colors.dart';

final lightTheme = ThemeData(
  textTheme: TextTheme(
    bodySmall: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.w400,
      fontSize: 14.sp,
      fontFamily: "Onest",
    ),
    bodyMedium: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.w500,
      fontSize: 14.sp,
      fontFamily: "Onest",
    ),
    titleMedium: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.w400,
      fontSize: 24.sp,
      fontFamily: "Onest",
    ),
    titleLarge: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.w400,
      fontSize: 36.sp,
      fontFamily: "Onest",
    ),
    headlineLarge: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.w700,
      fontSize: 36.sp,
      fontFamily: "Onest",
    ),
  ),
  extensions: <ThemeExtension>[
    CustomTheme(
      gradientBackground: LinearGradient(
        colors: [
          AppColors.backgroundGradient1,
          AppColors.backgroundGradient2,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      secondaryGradient: LinearGradient(
        colors: [
          AppColors.gradientText1,
          AppColors.gradientText2,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      textRedGradient: LinearGradient(
        colors: [
          AppColors.gradientTextRed1,
          AppColors.gradientTextRed2,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ],
);

class CustomTheme extends ThemeExtension<CustomTheme> {
  final LinearGradient gradientBackground;
  final LinearGradient secondaryGradient;
  final LinearGradient textRedGradient;

  const CustomTheme({
    required this.gradientBackground,
    required this.secondaryGradient,
    required this.textRedGradient,
  });

  @override
  CustomTheme copyWith({
    LinearGradient? gradientBackground,
    LinearGradient? secondaryGradient,
    LinearGradient? textRedGradient,
  }) {
    return CustomTheme(
      gradientBackground: gradientBackground ?? this.gradientBackground,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      textRedGradient: textRedGradient ?? this.textRedGradient,
    );
  }

  @override
  CustomTheme lerp(ThemeExtension<CustomTheme>? other, double t) {
    if (other is! CustomTheme) return this;
    return CustomTheme(
      gradientBackground: LinearGradient.lerp(
        gradientBackground,
        other.gradientBackground,
        t,
      )!,
      secondaryGradient: LinearGradient.lerp(
        secondaryGradient,
        other.secondaryGradient,
        t,
      )!,
      textRedGradient: LinearGradient.lerp(
        textRedGradient,
        other.textRedGradient,
        t,
      )!,
    );
  }
}
