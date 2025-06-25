import 'package:flutter/material.dart';
import 'package:snowplow/common/firstpage.dart';

import 'package:snowplow/user/Authentication/loginpage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/login': (context) => LoginScreen(),
      '/home': (context) => SplashScreen(),
    },
    debugShowCheckedModeBanner: false,
  ));
}

