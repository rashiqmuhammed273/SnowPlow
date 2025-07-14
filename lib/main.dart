// import 'package:flutter/material.dart';
// import 'package:snowplow/common/firstpage.dart';

// import 'package:snowplow/user/Authentication/loginpage.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   runApp(MaterialApp(
//     initialRoute: '/home',
//     routes: {
//       '/login': (context) => LoginScreen(),
//       '/home': (context) => SplashScreen(),
//     },
//     debugShowCheckedModeBanner: false,
//   ));
//   }

import 'package:flutter/material.dart';
import 'package:snowplow/common/firstpage.dart';
import 'package:snowplow/user/Authentication/loginpage.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // // Load theme preference
  // final prefs = await SharedPreferences.getInstance();
  // final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // final bool isDarkMode;
  const MyApp({super.key,});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnowPlow',
      debugShowCheckedModeBanner: false,
      // themeMode: ThemeMode.system,
      // theme: ThemeData(
      //   useMaterial3: true,
      //   brightness: Brightness.light,
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),),
      // ),
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   brightness: Brightness.dark,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.blue,
      //     brightness: Brightness.dark,
      //   ),
      // ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => SplashScreen(),
      },
    );
  }
}
