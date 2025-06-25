import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowplow/user/activerequest.dart';
import 'package:snowplow/user/pendingrequest.dart';
import 'package:snowplow/user/requestpage.dart';

// import your request page here
// import 'package:your_app/request_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;




  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
        if (!mounted) return; 
      setState(() {

      }); // to rebuild FAB visibility on tab switch
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToRequestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: _tabController.index == 0 || _tabController.index ==1
          ? FloatingActionButton(
              onPressed: _navigateToRequestPage,
              backgroundColor: const Color.fromARGB(255, 119, 185, 243),
              tooltip: 'Make a Request',
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 13),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 160, 200, 236),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.blueGrey.shade700,
                labelStyle: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: "Active"),
                  Tab(text: "Pending"),
           
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                 Activerequest(),
                 Pendingrequest(),
             
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String message) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.blueGrey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
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
      );
  }
}
