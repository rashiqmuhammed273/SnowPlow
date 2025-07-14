import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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
    String? companyId = prefs.getString("agency_id");
    String? userId = prefs.getString("userId");

    await Future.delayed(Duration(seconds: 2)); // Simulating splash delay

    if (companyId != null && companyId.isNotEmpty) {
      
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
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Landscreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 240, 245),
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 205, 228, 236)),
   body: Stack(
  children: [
    // 1️⃣ background colour (optional – you already set Scaffold.backgroundColor)
    Container(color: const Color.fromARGB(255, 205, 228, 236)),

    // 2️⃣ truck animation, full‑screen, touch‑transparent
    // Positioned(
      
    //  top: 90,
    //   left: 10,
    //   right: 10,
    //   child: IgnorePointer(
    //     child: Lottie.asset(
    //       'assets/truck animation.json',
    //       height: 150,
    //       width: 150,
          
            
    //       repeat: true,
    //     ),
    //   ),
    // ),

    // 3️⃣ centred title text
    Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(
          //   'Snow Plow',
          //   style: GoogleFonts.raleway(
          //     color: const Color.fromARGB(255, 115, 200, 240),
          //     fontSize: 60,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const SizedBox(height: 10),
          // Text(
          //   'Snow removal App',
          //   style: GoogleFonts.ptSansNarrow(
          //     color: const Color.fromARGB(255, 27, 130, 241),
          //     fontSize: 20,
          //   ),
          // ),
          Image.asset("assets/snowplowlogo.png",
          height: 400,width: 400,),
          
        ],
      ),
    ),
  ],
)

    );
  }
}
