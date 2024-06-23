import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lip_reading/core/theming/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LipReadingText extends StatelessWidget {
  var generatedText = '';
  LipReadingText({super.key, required this.generatedText});

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
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: generatedText == 'generated text will appear here...'
              ? AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Extracting text, please wait ...',
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                )
              : Text(
                  generatedText,
                  key: ValueKey<String>(generatedText),
                  style: const TextStyle(
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
