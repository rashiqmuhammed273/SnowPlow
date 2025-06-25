import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/companies/homepagee.dart';
import 'package:snowplow/companies/profile.dart';

class Cmpnavabar extends StatefulWidget {
  const Cmpnavabar({super.key});

  @override
  State<Cmpnavabar> createState() => _CmpnavabarState();
}

class _CmpnavabarState extends State<Cmpnavabar> {
  int _selectedIndex = 0; // Track selected tab
 
  String? hello;
  List<String>? profiledata;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCompanyId();
  }

  Future<void> getCompanyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profiledata = prefs.getStringList("agency_profile");
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      profiledata != null
          ? Tapbarscreen(agencydata:profiledata)
          : const Center(child: CircularProgressIndicator()),
      // Home Page

      Cmprofile(
        agencydetail: profiledata,
      ),
      // Profile Page
    ];
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: _selectedIndex == 1
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(80), // Adjust height as needed
              child: AppBar(
                centerTitle: true,
                backgroundColor: Color.fromARGB(255, 160, 200, 236),
                title: Text(
                  "Snow Plow",
                  style: GoogleFonts.raleway(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25), // Adjust curve here
                    bottomRight: Radius.circular(25),
                  ),
                ),
              ),
            ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 213, 240, 245),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
