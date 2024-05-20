// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously
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

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

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
            GestureDetector(
              onTap: () async {
                print("Attempting to connect to socket...");
                try {
                  // Establish socket connection
                  Socket socket = await Socket.connect("197.49.241.108", 5000);
                  print('Connected to socket!');

                  // Example: Send data
                  socket.write('test.mp4');
                  ByteData bytes =
                      await rootBundle.load('assets/videos/test.mp4');

                  var size = bytes.lengthInBytes;
                  socket.write(size);
                  List<int> imageData = bytes.buffer.asUint8List();
                  socket.add(imageData);
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
              },
              child: Container(
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
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                pickVideoFile();
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
          ],
        ),
      ),
    );
  }

  void openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }

  void pickVideoFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      // File file = File(result.files.single.path!);
      final file = result.files.first;
      openFile(file);
    } else {
      // User canceled the picker
      return;
    }
  }
}
