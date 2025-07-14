

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/user/homepage.dart';
import 'package:snowplow/user/profilepage.dart';
import 'package:snowplow/user/showcompany.dart';

// App Theme Configuration
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
    centerTitle: false, // Changed to false for our custom layout
    scrolledUnderElevation: 5,
    titleTextStyle: GoogleFonts.raleway(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.black87,
    ),
  ),
);

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String? userId;
  late AnimationController _screenTransitionController;
  late Animation<double> _screenTransitionAnimation;
  late AnimationController _navBarController;
  late Animation<double> _navBarAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserId();
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

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString("userId");
      });
      debugPrint("User ID loaded: $userId");
    } catch (e) {
      debugPrint("Error loading user ID: $e");
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

PreferredSizeWidget? _buildAppBar() {
  return AppBar(
    toolbarHeight: 70, // Reduced from original height
    title: Container(
      height: 70, // Match toolbarHeight
      alignment: Alignment.bottomCenter, // Align content to bottom
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom
        children: [
          Text(
            _getPageTitle(),
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.w700,
              fontSize: 27,
              color:const Color.fromARGB(255, 75, 136, 249)
            ),
          ),
          Image.asset(
            'assets/snowplowlogo.png',
            width: 110,
            fit: BoxFit.contain,
          ),
        ],
      ),
    ),flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
        child: Container(
          color: Colors.transparent,
        ),
      ),
    ),
   
  );
}



  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return '.Companies';
      case 1:
        return '.Requests';
      case 2:
        return '.Profile';
      default:
        return 'SnowPlowPro';
    }
  }

  Widget _buildContent() {
    final screens = [
      FadeTransition(
        opacity: _screenTransitionAnimation,
        child: const Showcompany(),
      ),
      FadeTransition(
        opacity: _screenTransitionAnimation,
        child: const HomeScreen(),
      ),
      FadeTransition(
        opacity: _screenTransitionAnimation,
        child: userId != null
            ? ProfileScreen(UserId: userId!)
            : const Center(child: CircularProgressIndicator()),
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
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
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
          icon: Icons.request_page_outlined,
          activeIcon: Icons.request_page,
        ),
        label: 'Requests',
        tooltip: 'Service Requests',
      ),
      BottomNavigationBarItem(
        icon: _AnimatedNavIcon(
          selected: _selectedIndex == 2,
          icon: Icons.person_outline,
          activeIcon: Icons.person,
        ),
        label: 'Profile',
        tooltip: 'User Profile',
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