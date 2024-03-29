import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/pages/home_page.dart';

import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //taking location permission
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission){
    if(valueOfPermission){
        //when denied is true
      Permission.locationWhenInUse.request();
    }
  });
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: FirebaseAuth.instance.currentUser==null?const LoginScreen():const HomePage(),
    );
  }
}


