import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChangeAvatar extends StatefulWidget {
  const ChangeAvatar({Key? key}) : super(key: key);

  @override
  ChangeAvatarState createState() => ChangeAvatarState();
}

class ChangeAvatarState extends State<ChangeAvatar> {
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final cropped = await _cropImage(File(pickedFile.path));
      setState(() {
        _imageFile = cropped;
      });
    }
  }

  Future<File> _cropImage(File imageFile) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      maxWidth: 200,
      maxHeight: 200,
      compressQuality: 100,
      cropStyle: CropStyle.rectangle,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 200,
            height: 200,
          ),
          viewPort:
              const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    return imageFile;
  }

  Future<void> _pickImageFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> _pickImageFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 75,
      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
      child: _imageFile == null ? Text('Add\nPhoto') : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile Picture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Select Image Source'),
                    children: [
                      SimpleDialogOption(
                        child: const Text('Camera'),
                        onPressed: () {
                          _pickImageFromCamera();
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('Gallery'),
                        onPressed: () {
                          _pickImageFromGallery();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              ),
              child: _buildProfilePicture(),
            ),
          ],
        ),
      ),
    );
  }
}
