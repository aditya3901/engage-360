import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Welcome(),
    );
  }
}
