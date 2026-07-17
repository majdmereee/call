import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // التهيئة اليدوية المباشرة باستخدام بيانات مشروعك الفعلي من الملف
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBochg6o4aY5nYK_hgSA-OKPPJBWNq4W8g",
      appId: "1:561315856725:android:fad6b8868605563cacafdc",
      messagingSenderId: "561315856725", // هو نفسه الـ project_number
      projectId: "soos-e2bbb",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alert App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Firebase متصل بنجاح بمشروع soos!'),
        ),
      ),
    );
  }
}
