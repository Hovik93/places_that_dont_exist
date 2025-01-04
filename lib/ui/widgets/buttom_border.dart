import 'package:flutter/material.dart';
import 'package:places_that_dont_exist/base/colors.dart';

class BottomBorderContainer extends StatelessWidget {
  final Widget child;

  const BottomBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff212B2B),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.01),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey,
            width: 0.2,
          ),
        ),
      ),
      child: child,
    );
  }
}
