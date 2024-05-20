// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, unused_field
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lip_reading/core/helpers/extensions.dart';
import 'package:lip_reading/core/routing/routes.dart';
import 'package:lip_reading/core/theming/colors.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:open_file/open_file.dart';
import 'widgets/lip_reading_text.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  PlatformFile? _pickedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('home page'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.pushNamedAndRemoveUntil(Routes.loginScreen,
                  predicate: (Route<dynamic> route) => false);
            },
            icon: const Icon(
              Icons.exit_to_app,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          children: [
            SizedBox(
              height: 40.h,
            ),
            LipReadingText(),
            SizedBox(
              height: 20.h,
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      PlatformFile? pickedFile = await pickVideoFile();
                      if (pickedFile != null) {
                        setState(() {
                          _pickedFile = pickedFile;
                        });
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(ColorsManager.mainBlue),
                    ),
                    child: Text(
                      'Choose File',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_pickedFile != null) {
                        connectAndSendData(_pickedFile!);
                      } else {
                        print("No file selected");
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(ColorsManager.mainBlue),
                    ),
                    child: Text(
                      'Generate Text',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
      // openFile(file);
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
      Socket socket = await Socket.connect("102.40.42.199", 5000);
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
