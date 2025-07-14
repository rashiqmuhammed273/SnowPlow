// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:snowplow/Animation.dart';
// // import 'package:snowplow/companies/homepagee.dart';
// // import 'package:snowplow/companies/profile.dart';

// // class Cmpnavabar extends StatefulWidget {
// //   const Cmpnavabar({super.key});

// //   @override
// //   State<Cmpnavabar> createState() => _CmpnavabarState();
// // }

// // class _CmpnavabarState extends State<Cmpnavabar> {
// //   int _selectedIndex = 0; // Track selected tab

// //   String? hello;
// //   String? profiledata;

// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }

// //   @override
// //   void initState() {
// //     // TODO: implement initState
// //     super.initState();
// //     getCompanyId();
// //   }

// //   Future<void> getCompanyId() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       profiledata = prefs.getString("agency_id");
// //     });
// //     print('agencyude id is $profiledata');
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     List<Widget> getPages() {
// //       if (profiledata == null) {
// //         return [
// //           SnowLoader(), // while waiting for data
// //           SnowLoader(), // same for profile
// //         ];
// //       }

// //       return [
// //         Tapbarscreen(agencydata: profiledata!),
// //         Cmprofile(agencyid: profiledata!),
// //       ];
// //     }

// //     return Scaffold(
// //       backgroundColor: Color.fromARGB(255, 255, 255, 255),
// //       appBar: _selectedIndex == 1
// //           ? null
// //           : PreferredSize(
// //               preferredSize: Size.fromHeight(80), // Adjust height as needed
// //               child: AppBar(
// //                 centerTitle: true,
// //                 backgroundColor: Color.fromARGB(255, 160, 200, 236),
// //                 title: Text(
// //                   "Snow Plow",
// //                   style: GoogleFonts.raleway(
// //                     color: const Color.fromARGB(255, 255, 255, 255),
// //                     fontSize: 40,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 shape: const RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.only(
// //                     topLeft: Radius.circular(25),
// //                     topRight: Radius.circular(25),
// //                     bottomLeft: Radius.circular(25), // Adjust curve here
// //                     bottomRight: Radius.circular(25),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //       body: IndexedStack(
// //         index: _selectedIndex,
// //         children: getPages(),
// //       ),
// //       bottomNavigationBar: BottomNavigationBar(
// //         backgroundColor: const Color.fromARGB(255, 213, 240, 245),
// //         items: const [
// //           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
// //           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
// //         ],
// //         currentIndex: _selectedIndex,
// //         selectedItemColor: Colors.blue.shade900,
// //         unselectedItemColor: Colors.grey,
// //         onTap: _onItemTapped,
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snowplow/Animation.dart';
// import 'package:snowplow/companies/homepagee.dart';
// import 'package:snowplow/companies/profile.dart';

// class Cmpnavabar extends StatefulWidget {
//   const Cmpnavabar({super.key});

//   @override
//   State<Cmpnavabar> createState() => _CmpnavabarState();
// }

// class _CmpnavabarState extends State<Cmpnavabar> {
//   int _selectedIndex = 0; // Track selected tab

//   String? hello;
//   String? profiledata;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     getCompanyId();
//   }

//   Future<void> getCompanyId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       profiledata = prefs.getString("agency_id");
//     });
//     print('agencyude id is $profiledata');
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> getPages() {
//       if (profiledata == null) {
//         return [
//           SnowLoader(), // while waiting for data
//           SnowLoader(), // same for profile
//         ];
//       }

//       return [
//         Tapbarscreen(agencydata: profiledata!),
//         Cmprofile(agencyid: profiledata!),
//       ];
//     }

//     return Scaffold(
//       backgroundColor: Color(0xFFF5F5F5), // Light grey background
//       appBar: _selectedIndex == 1
//           ? null
//           : AppBar(
//               centerTitle: true,
//               backgroundColor: Color(0xFF0D47A1), // Dark blue color
//               elevation: 0,
//               title: Text(
//                 "Snow Plow",
//                 style: GoogleFonts.raleway(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.vertical(
//                   bottom: Radius.circular(20), // Rounded bottom corners
//                 ),
//               ),
//             ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: getPages(),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           child: BottomNavigationBar(
//             backgroundColor: Colors.white,
//             items: [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: "Home",
//                 activeIcon: Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF0D47A1).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(Icons.home, color: Color(0xFF0D47A1)),
//                 ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.person),
//                 label: "Profile",
//                 activeIcon: Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF0D47A1).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(Icons.person, color: Color(0xFF0D47A1)),
//                 ),
//             ],
//             currentIndex: _selectedIndex,
//             selectedItemColor: Color(0xFF0D47A1), // Dark blue color
//             unselectedItemColor: Colors.grey,
//             showUnselectedLabels: true,
//             type: BottomNavigationBarType.fixed,
//             onTap: _onItemTapped,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/Animation.dart';
import 'package:snowplow/companies/homepagee.dart';
import 'package:snowplow/companies/profile.dart';

// App Theme Configuration (same as user side)
final _appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF3A7FD5),
    brightness: Brightness.light,
    primary: const Color(0xFF3A7FD5),
    secondary: const Color(0xFF6C63FF),
    tertiary: const Color(0xFFF8F9FA),
  ),
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 5,
    titleTextStyle: GoogleFonts.raleway(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.black87,
    ),
  ),
);

class Cmpnavabar extends StatefulWidget {
  const Cmpnavabar({super.key});

  @override
  State<Cmpnavabar> createState() => _CmpnavabarState();
}

class _CmpnavabarState extends State<Cmpnavabar> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String? profiledata;
  late AnimationController _screenTransitionController;
  late Animation<double> _screenTransitionAnimation;
  late AnimationController _navBarController;
  late Animation<double> _navBarAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCompanyId();
  }

  void _initializeAnimations() {
    _screenTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _screenTransitionAnimation = CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.fastOutSlowIn,
    );

    _navBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _navBarAnimation = CurvedAnimation(
      parent: _navBarController,
      curve: Curves.easeOut,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _screenTransitionController.forward();
      _navBarController.forward();
    });
  }

  Future<void> _loadCompanyId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        profiledata = prefs.getString("agency_id");
      });
      debugPrint("Agency ID loaded: $profiledata");
    } catch (e) {
      debugPrint("Error loading agency ID: $e");
    }
  }

  @override
  void dispose() {
    _screenTransitionController.dispose();
    _navBarController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
      _screenTransitionController.reset();
      _screenTransitionController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _appTheme,
      child: Scaffold(
        backgroundColor: _appTheme.colorScheme.tertiary,
        extendBody: true,
        appBar: _buildAppBar(),
        body: _buildContent(),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

// Add this at the top

PreferredSizeWidget? _buildAppBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(110),
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 149, 215, 255).withOpacity(0.3), // Semi-transparent
          elevation: 0,
          toolbarHeight: 110,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getPageTitle(),
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                  color: const Color(0xFF4B88F9),
                ),
              ),
              Image.asset(
                'assets/snowplowlogo.png',
                width: 110,
                fit: BoxFit.contain,
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      ),
    ),
  );
}

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return '.Company Home';
      case 1:
        return '.Profile';
      default:
        return 'SnowPlowPro';
    }
  }

  Widget _buildContent() {
    final screens = [
      FadeTransition(
        opacity: _screenTransitionAnimation,
        child: profiledata != null
            ? Tapbarscreen(agencydata: profiledata!)
            : const SnowLoader(),
      ),
      FadeTransition(
        opacity: _screenTransitionAnimation,
        child: profiledata != null
            ? Cmprofile(agencyid: profiledata!)
            : const SnowLoader(),
      ),
    ];

    return PageTransitionSwitcher(
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: Colors.transparent,
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: screens[_selectedIndex],
    );
  }

  Widget _buildBottomNavBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_navBarAnimation),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      height:
                          kBottomNavigationBarHeight + 12, // Adjust if needed
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.3), // transparent white
                        border: const Border(
                          top: BorderSide(color: Colors.white24, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
                BottomNavigationBar(
                  backgroundColor: Colors.transparent, // Important!
                  elevation: 0,
                  items: _buildNavItems(),
                  currentIndex: _selectedIndex,
                  selectedItemColor: _appTheme.colorScheme.primary,
                  unselectedItemColor: Colors.grey.shade500,
                  selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  onTap: _onItemTapped,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return [
      BottomNavigationBarItem(
        icon: _AnimatedNavIcon(
          selected: _selectedIndex == 0,
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
        ),
        label: 'Home',
        tooltip: 'Home',
      ),
      BottomNavigationBarItem(
        icon: _AnimatedNavIcon(
          selected: _selectedIndex == 1,
          icon: Icons.person_outline,
          activeIcon: Icons.person,
        ),
        label: 'Profile',
        tooltip: 'Company Profile',
      ),
    ];
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final IconData activeIcon;

  const _AnimatedNavIcon({
    required this.selected,
    required this.icon,
    required this.activeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: selected
          ? Icon(activeIcon, key: const ValueKey('active'))
          : Icon(icon, key: const ValueKey('inactive')),
    );
  }
}
