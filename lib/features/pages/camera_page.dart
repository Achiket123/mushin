import 'dart:io';

import 'package:control/features/pages/home_page.dart';
import 'package:control/features/service/api_service.dart';
import 'package:control/features/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:control/features/bloc/lock_bloc/lock_bloc.dart' as lb;

late List<CameraDescription> cameras;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.package});
  final String package;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  static const platform = MethodChannel('lock_app_service');
  CameraController? controller;
  XFile? imageFile;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await platform.invokeMethod<String?>("argument-delete");
    });
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller!
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // Handle access errors here.
                break;
              default:
                // Handle other errors here.
                break;
            }
          }
        });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(height, width),
      backgroundColor: Color.fromARGB(255, 45, 45, 45),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 217, 217, 217),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: width * 1,
                  height: height * 0.7,
                  child: ClipRRect(
                    child:
                        imageFile != null
                            ? Image.file(File(imageFile!.path))
                            : CameraPreview(controller!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                if (isLoading) return;
                controller!.takePicture().then((XFile? file) async {
                  if (file != null) {
                    // Handle the captured image file here.
                    print('Image saved to ${file.path}');
                    setState(() {
                      imageFile = file;
                      isLoading = true;
                    });
                    final data = await ApiService().uploadPhoto(file.path);
                    showDialog(
                      context: context,
                      builder:
                          (context) => SizedBox(
                            height: 200,
                            child: Dialog(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      data
                                          ? "We Can Confirm That You are Outside You can open the app"
                                          : "We are not seeing any greenery please go outside",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      lb.LockBloc().add(
                                        lb.LockAppEvent(widget.package),
                                      );
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(),
                                        ),
                                      );
                                      platform.invokeMethod("open-app", {
                                        "package": widget.package,
                                      });
                                    },
                                    child: Text("OK"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Color.fromARGB(150, 0, 0, 0),
                    width: 5,
                  ),
                ),
                width: 75,
                height: 75,
                child:
                    isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
