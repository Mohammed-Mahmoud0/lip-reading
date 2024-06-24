// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, unused_field, constant_identifier_names, unused_import
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lip_reading/core/helpers/extensions.dart';
import 'package:lip_reading/core/routing/routes.dart';
import 'package:lip_reading/core/theming/colors.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:lip_reading/core/theming/style.dart';
import 'package:lip_reading/core/widgets/app_text_button.dart';
import 'package:open_file/open_file.dart';
import 'widgets/lip_reading_text.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  PlatformFile? _pickedFile;
  var generatedText = 'generated text will appear here...';
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: ColorsManager.mainBlue,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.pushNamedAndRemoveUntil(Routes.loginScreen,
                  predicate: (Route<dynamic> route) => false);
            },
            icon: const Icon(
              Icons.logout,
              color:  ColorsManager.mainBlue,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/lipReading_logo_low_opacity.png"), // Your logo image path
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Column(
            children: [
              SizedBox(
                height: 32.h,
              ),
              LipReadingText(
                generatedText: generatedText,
              ),
              SizedBox(
                height: 20.h,
              ),
              Spacer(),
              AppTextButton(
                buttonText: 'Choose File',
                textStyle: TextStyles.font16whitesemibold,
                onPressed: () async {
                  PlatformFile? pickedFile = await pickVideoFile();
                  if (pickedFile != null) {
                    setState(() {
                      _pickedFile = pickedFile;
                    });
                  }
                },
              ),
              SizedBox(
                height: 10.h,
              ),
              AppTextButton(
                buttonText: 'Generate Text',
                textStyle: TextStyles.font16whitesemibold,
                onPressed: () async {
                  if (_pickedFile != null) {
                    connectAndSendData(_pickedFile!);
                  } else {
                    print("No file selected");
                  }
                },
              ),
              SizedBox(
                height: 40.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<PlatformFile?> pickVideoFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      // File file = File(result.files.single.path!);
      final file = result.files.first;
      openFile(file);
      return file;
    } else {
      // User canceled the picker
      return null;
    }
  }

  void openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }

  void connectAndSendData(PlatformFile file) async {
    print("Attempting to connect to socket...");
    try {
      // Establish socket connection
      Socket socket = await Socket.connect("197.49.156.63", 5050);
      print('Connected to socket!');

      // Example: Send data
      socket.write(file.name);

      // Read file as bytes
      List<int> fileBytes = await File(file.path!).readAsBytes();

      socket.write(fileBytes.length);

      socket.add(fileBytes);

      socket.write("<END>");

      print("done");

      // Example: Listen for responses
      socket.listen((List<int> data) {
        if (String.fromCharCodes(data) == 'ERROR') {
          setState(() {
            isError = true;
          });
        }

        if (String.fromCharCodes(data) != '' && !isError) {
          showToast(text: 'Success generated', state: ToastStates.SUCCESS);
          setState(() {
            generatedText = String.fromCharCodes(data);
          });
        } else {
          showToast(text: generatedText, state: ToastStates.ERROR);
        }
        print(generatedText);
        print('Received data: ${String.fromCharCodes(data)}');
        // Handle received data here
      });

      // Close the socket when done
      socket.close();
    } catch (e) {
      print('Error connecting to socket: $e');
      // Handle error
    }
  }
}

void showToast({
  required String text,
  required ToastStates state,
}) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 16.0);
}

enum ToastStates {
  SUCCESS,
  ERROR,
  WARNING,
}

Color chooseToastColor(ToastStates state) {
  Color color;
  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }
  return color;
}
