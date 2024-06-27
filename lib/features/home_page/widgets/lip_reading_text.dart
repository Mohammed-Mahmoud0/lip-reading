import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lip_reading/core/theming/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// ignore: must_be_immutable
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
        borderRadius: BorderRadius.circular(16.0),
        gradient: const LinearGradient(
          colors: [ColorsManager.mainBlue, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: generatedText == 'Please select a video' ||
                  generatedText ==
                      'Great! Now click Generate Text to proceed.' ||
                  generatedText == 'Extracting text, Please wait ...' ||
                  generatedText == 'Error occurred while extracting text'
              ? AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      generatedText,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                      speed: const Duration(milliseconds: 100),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                )
              : Column(
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Extracted Text!',
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Georgia',
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      isRepeatingAnimation: true,
                      repeatForever: true,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      generatedText,
                      key: ValueKey<String>(generatedText),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
