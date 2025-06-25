import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Activerequest extends StatelessWidget {
  const Activerequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), // Curve on top-left
            topRight: Radius.circular(30), // Curve on top-right
          ),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 201, 218, 234),
              Color.fromARGB(255, 221, 233, 239),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 60, color: Colors.blueGrey.shade300),
              const SizedBox(height: 12),
              Text(
                "NO Active requests available",
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Your updates will appear here",
                style: GoogleFonts.ptSans(color: Colors.blueGrey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
