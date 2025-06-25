import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/user/homepage.dart';
import 'package:snowplow/user/profilepage.dart';
import 'package:snowplow/user/showcompany.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int _selectedindex = 0;
  String? userId;
  bool isLoading = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loaduserId();
  }

  Future<void> _loaduserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("userId");
     
      isLoading = false;
    });
     print("🔍 Loaded userId from SharedPreferences: $userId");
  }

  @override   
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Showcompany(),
      HomeScreen(),
     
      userId != null
          ? ProfileScreen(UserId: userId!)
          : const Center(child: CircularProgressIndicator())
    ];


    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 160, 200, 236),
      appBar: (_selectedindex == 2)
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: AppBar(
                centerTitle: true,
                toolbarHeight: 76,
                backgroundColor: const Color.fromARGB(255, 160, 200, 236),
                title: Text(
                  "Snow Plow",
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
      body: IndexedStack(
        index: _selectedindex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 160, 200, 236),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.inbox_outlined), label: "Request"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedindex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
