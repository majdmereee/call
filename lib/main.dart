import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBochg6o4aY5nYK_hgSA-OKPPJBWNq4W8g",
      appId: "1:561315856725:android:fad6b8868605563cacafdc",
      messagingSenderId: "561315856725",
      projectId: "soos-e2bbb",
    ),
  );
  
  String callerName = message.data['caller_name'] ?? 'شخص ما يطلب المساعدة!';
  String battery = message.data['battery'] ?? 'غير معروف';
  String location = message.data['location'] ?? '';

  _showIncomingCallWindow(callerName, battery, location);
}

// هذه هي الدالة التي تم تصحيحها (بدون textAccept و textDecline)
Future<void> _showIncomingCallWindow(String name, String battery, String location) async {
  CallKitParams params = CallKitParams(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    nameCaller: name,
    appName: "Instant SOS",
    handle: "نسبة شحن البطارية: $battery%",
    type: 0,
    extra: <String, dynamic>{'location_url': location},
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#d32f2f',
      textColor: '#ffffff',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBochg6o4aY5nYK_hgSA-OKPPJBWNq4W8g",
      appId: "1:561315856725:android:fad6b8868605563cacafdc",
      messagingSenderId: "561315856725",
      projectId: "soos-e2bbb",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    _setupAppRequirements();
  }

  void _setupAppRequirements() async {
    await FirebaseMessaging.instance.requestPermission(alert: true, sound: true);
    await Geolocator.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic("all_users");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String callerName = message.data['caller_name'] ?? 'نداء جديد';
      String battery = message.data['battery'] ?? 'غير معروف';
      String location = message.data['location'] ?? '';
      _showIncomingCallWindow(callerName, battery, location);
    });
  }

  void _triggerEmergencyAlert() async {
    String username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم المستخدم أولاً!')),
      );
      return;
    }

    int batteryLevel = await _battery.batteryLevel;
    String locationUrl = "لا يوجد موقع";
    
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      locationUrl = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
    } catch (e) {
      locationUrl = "صلاحية الموقع مرفوضة";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تجميع البيانات! جاهز للربط مع سيرفر الإرسال يا $username.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نظام النداء الجماعي السريع')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم (المتصل)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _triggerEmergencyAlert,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(60),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 10,
              ),
              child: const Text(
                'اضغط\nللـرن للكل',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
