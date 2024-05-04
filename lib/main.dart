import 'package:flutter/material.dart';
import 'package:lip_reading/core/routing/app_router.dart';
import 'package:lip_reading/lip_reading_app.dart';

void main() {
  runApp(LipReadingApp(
    appRouter: AppRouter(),
  ));
}
