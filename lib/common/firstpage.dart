import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/companies/bottmnav.dart';
import 'package:snowplow/common/landingpage.dart';
import 'package:snowplow/user/bottomnav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override

  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? companyId = prefs.getStringList("agency_profile");
    String? userId = prefs.getString("userId");

    await Future.delayed(Duration(seconds: 2)); // Simulating splash delay

    if (companyId != null && companyId.isNotEmpty) {
      // ✅ User is logged in, navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Cmpnavabar()),
      );
    } else if (userId != null && userId.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Bottomnavbar()),
      );
    } else {
      // ❌ No session found, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Landscreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 240, 245),
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 205, 228, 236)),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 205, 228, 236),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
              'Snow Plow',
              style: GoogleFonts.raleway(
                  color: const Color.fromARGB(255, 115, 200, 240),
                  fontSize: 60,
                  fontWeight: FontWeight.bold),
            )),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
              'Snow removal App',
              style: GoogleFonts.ptSansNarrow(
                  color: const Color.fromARGB(255, 27, 130, 241), fontSize: 20),
            ))
          ],
        ),
      ),
    );
  }
}
