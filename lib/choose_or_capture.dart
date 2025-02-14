// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:face_detection_app/model/face_detector_model.dart';
import 'package:face_detection_app/utils/face_painter.dart';
import 'package:face_detection_app/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

class ChooseOrCapture extends StatefulWidget {
  const ChooseOrCapture({super.key});

  @override
  State<ChooseOrCapture> createState() => _ChooseOrCaptureState();
}

class _ChooseOrCaptureState extends State<ChooseOrCapture> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<Face> _faces = [];
  ui.Image? _imageUi;
  bool _isLoading = false;

  Future<void> chooseImage() async {
    setState(() {
      _isLoading = true;
    });
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File imageFile = File(image.path);
      await detectFaces(imageFile);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> detectFaces(File imageFile) async {
    final faceDetectorModel = FaceDetectorModel();
    List<Face> faces = await faceDetectorModel.detectFaces(imageFile);
    setState(() {
      _image = imageFile;
      _faces = faces;
    });
    await loadImage(imageFile);
  }

  Future<void> loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) {
      setState(() {
        _imageUi = value;
      });
    });
  }

  Future<void> captureImage() async {
    setState(() {
      _isLoading = true;
    });
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final File imageFile = File(photo.path);
      await detectFaces(imageFile);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void clearImage() {
    setState(() {
      _image = null;
      _faces = [];
      _imageUi = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Face Recognition',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.purple.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Faces Detected: ${_faces.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomPaint(
                            painter: _imageUi != null
                                ? FacePainter(_imageUi!, _faces)
                                : null,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No Image Selected',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    )
                  : Column(
                      children: [
                        CustomElevatedButton(
                          text: 'Capture Image',
                          onPressed: captureImage,
                          icon: Icons.camera_alt,
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        CustomElevatedButton(
                          text: 'Choose Image',
                          onPressed: chooseImage,
                          icon: Icons.photo_library,
                          backgroundColor: Colors.purple,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        CustomElevatedButton(
                          text: 'Clear Image',
                          onPressed: clearImage,
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: captureImage,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}