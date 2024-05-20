import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lip_reading/core/theming/colors.dart';


class LipReadingText extends StatelessWidget {
  const LipReadingText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400.w,
      height: 200.h,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15.0),
        gradient: const LinearGradient(
          colors: [ColorsManager.mainBlue, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Text(
            'This is a static text that cannot be edited by the user.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}