import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowplow/companies/authentication/loginpage.dart';
import 'package:snowplow/user/Authentication/loginpage.dart';

class Landscreen extends StatelessWidget {
  const Landscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 240, 245),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Snow Plow',
              style: GoogleFonts.raleway(
                  color: const Color.fromARGB(255, 115, 200, 240),
                  fontSize: 60,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Snow removal App',
              style: GoogleFonts.tajawal(
                  color: const Color.fromARGB(255, 27, 130, 241), fontSize: 20),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                 Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Cmplogin()));

               
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(27, 172, 233, 1)),
              child: Text(
                'Become a shoveler',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                 Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(5, 134, 174, 1)),
              child: Text(
                'Request a shoveler',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
