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
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(),

      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color.fromARGB(255, 0, 71, 224),

              Color.fromARGB(255, 15, 8, 118),
            ],
            center: Alignment.bottomLeft,
            radius: 1,
          ),
        ),
        child: SingleChildScrollView(
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
                      borderRadius: BorderRadius.circular(10),
                      child:
                          imageFile != null
                              ? Image.file(File(imageFile!.path))
                              : CameraPreview(controller!),
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
                            (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.white,
                              child: Container(
                                height: 400,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      data
                                          ? Icons.verified_outlined
                                          : Icons.warning_amber_outlined,
                                      size: 48,
                                      color: data ? Colors.green : Colors.red,
                                    ),

                                    Text(
                                      data
                                          ? "We can confirm that you are outside.\nYou can now open the app."
                                          : "No greenery detected.\nPlease go outside and try again.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        backgroundColor:
                                            data ? Colors.green : Colors.grey,
                                      ),
                                      onPressed: () {
                                        if (data) {
                                          lb.LockBloc().add(
                                            lb.LockAppEvent(widget.package),
                                          );

                                          platform.invokeMethod("open-app", {
                                            "package": widget.package,
                                          });
                                          SystemNavigator.pop();
                                        }

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => HomePage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
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
                      isLoading
                          ? CircularProgressIndicator()
                          : SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
