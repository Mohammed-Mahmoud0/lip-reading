// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, unused_field, constant_identifier_names, unused_import
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lip_reading/core/helpers/extensions.dart';
import 'package:lip_reading/core/routing/routes.dart';
import 'package:lip_reading/core/theming/colors.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:lip_reading/core/theming/style.dart';
import 'package:lip_reading/core/widgets/app_text_button.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';
import 'widgets/lip_reading_text.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  PlatformFile? _pickedFile;
  VideoPlayerController? _videoPlayerController;
  var generatedText = 'generated text will appear here...';
  bool isError = false;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

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
              color: ColorsManager.mainBlue,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage("assets/images/lipReading_logo_low_opacity.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 32.h,
                ),
                if (_videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_videoPlayerController!.value.isPlaying) {
                          _videoPlayerController!.pause();
                        } else {
                          _videoPlayerController!.play();
                        }
                      });
                    },
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      ),
                    ),
                  ),
                if (_videoPlayerController != null)
                  SizedBox(
                    height: 50.h,
                  ),
                if (_videoPlayerController == null)
                  Center(
                    child: Image.asset(
                      'assets/images/no-video0.png',
                      height: 250.h,
                      width: 250.w,
                    ),
                  ),
                SizedBox(
                  height: 70.h,
                ),
                LipReadingText(
                  generatedText: generatedText,
                ),
                SizedBox(
                  height: 40.h,
                ),
                AppTextButton(
                  buttonText: 'Choose File',
                  textStyle: TextStyles.font16whitesemibold,
                  onPressed: () async {
                    PlatformFile? pickedFile = await pickVideoFile();
                    if (pickedFile != null) {
                      setState(() {
                        _pickedFile = pickedFile;
                        _videoPlayerController =
                            VideoPlayerController.file(File(_pickedFile!.path!))
                              ..initialize().then((_) {
                                setState(() {});
                                // _videoPlayerController!.play();
                              });
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
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     PlatformFile? pickedFile = await takeVideoFromCamera();
      //     if (pickedFile != null) {
      //       setState(() {
      //         _pickedFile = pickedFile;
      //         _videoPlayerController =
      //             VideoPlayerController.file(File(_pickedFile!.path!))
      //               ..initialize().then((_) {
      //                 setState(() {});
      //                 // _videoPlayerController!.play();
      //               });
      //       });
      //     }
      //   },
      //   backgroundColor: Colors.blue,
      //   child: Icon(Icons.camera_alt),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  // Future<PlatformFile?> takeVideoFromCamera() async {
  //   final ImagePicker _picker = ImagePicker();
  //   final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
  //
  //   if (video != null) {
  //     File videoFile = File(video.path);
  //     return PlatformFile(
  //       name: video.name,
  //       path: video.path,
  //       size: await videoFile.length(),
  //       bytes: await videoFile.readAsBytes(),
  //     );
  //   } else {
  //     return null;
  //   }
  // }

  void openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }

  void connectAndSendData(PlatformFile file) async {
    print("Attempting to connect to socket...");
    try {
      // Establish socket connection
      Socket socket = await Socket.connect("192.168.1.7", 5050);
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
          showToast(text: 'Success Extracted', state: ToastStates.SUCCESS);
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
