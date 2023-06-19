import 'package:tripnow/screens/splash.dart';
import 'package:tripnow/screens/wrapper.dart';
import 'package:tripnow/screens/your_profile.dart';
// import 'package:tripnow/screens/camera.dart';
import 'package:flutter/material.dart';
import 'package:tripnow/screens/home.dart';
import 'package:tripnow/screens/detail_wisata.dart';
// import 'package:tripnow/screens/auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tripnow/models/auth_user.dart';
import 'package:tripnow/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AuthUser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        title: 'Tripnow',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/splash',
        routes: {
          '/': (context) => const Wrapper(),
          '/home': (context) => const Home(),
          '/detail_toko': (context) => const DetailToko(),
          '/your_profile': (context) => YourProfile(),
          '/splash': (context) => Splash(),
        },
      ),
    );
  }
}
