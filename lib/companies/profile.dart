import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cmprofile extends StatefulWidget {
  final List<String>? agencydetail;
  const Cmprofile({super.key, required this.agencydetail});

  @override
  State<Cmprofile> createState() => _CmprofileState();
}

class _CmprofileState extends State<Cmprofile> {
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();

  String? companyId;

  @override
  void initState() {
    super.initState();
    // getUserId();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? profiledata = prefs.getStringList("agency_profile");

    print(profiledata);

    if (profiledata != null) {
      companyId = profiledata[0];
      nameController.text = profiledata[1];
      emailController.text = profiledata[2];
      contactController.text = profiledata[3];
    } else {
      print("profiledata is null");
    }
    if (companyId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login again")),
        );
      }
      return;
    }
  }

/////////alert for logout////////
  void showlogoutDialogue() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("logout Profile",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            content: Text(
                "Are you sure you want to logout this profile? you have to login again if you logout ",
                style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 4, 144, 231))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel",
                    style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 0, 0, 250))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  logoutUser();
                },
                child: Text("Logout",
                    style: GoogleFonts.poppins(color: Colors.red)),
              ),
            ],
          );
        });
  }

  ///logoutusercode////
  void logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("agency_profile");
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/home",
      (route) => false,
    );
  }

////alert for delete////
  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Delete Profile",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          content: Text(
              "Are you sure you want to delete this profile? This action cannot be undone.",
              style: GoogleFonts.poppins(color: Colors.black87)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteCustomerprofile();
              },
              child:
                  Text("Delete", style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

////delete profile///
  Future<void> deleteCustomerprofile() async {
    if (companyId == null) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("userId");
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FD), // Lighter background
      body: CustomScrollView(
        slivers: [
          // App Bar with Blur Effect
          SliverAppBar(
            expandedHeight: 70,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(210, 155, 209, 244), // Glass effect
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
              ),
            ),
            title: Text(
              nameController.text.isNotEmpty ? nameController.text : "Profile",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
          ),

          // Profile Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // Floating Profile Avatar
                  Container(
                    transform: Matrix4.translationValues(0, -40, 0),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: Icon(
                        Icons.person_rounded,
                        size: 70,
                        color: const Color(0xFF4A90E2).withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Profile Card with Neumorphism
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        _buildModernProfileField("Name", nameController),
                        const SizedBox(height: 16),
                        _buildModernProfileField("Email", emailController),
                        const SizedBox(height: 16),
                        _buildModernProfileField("Phone", contactController),
                        const SizedBox(height: 32),
                        _buildModernButton(
                          icon: Icons.edit_rounded,
                          label: "Edit Profile",
                          color: const Color(0xFF4A90E2),
                          onPressed: () =>
                              Navigator.pushNamed(context, "/editProfile"),
                        ),
                        const SizedBox(height: 12),
                        _buildModernButton(
                          icon: Icons.delete_rounded,
                          label: "Delete Account",
                          color: const Color(0xFFE94E77),
                          isDestructive: true,
                          onPressed: showDeleteConfirmationDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button (Floating)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, size: 20),
                      label: Text("Sign Out",
                          style: GoogleFonts.poppins(fontSize: 15)),
                      onPressed: showlogoutDialogue,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7B8794),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                            color: const Color(0xFF7B8794).withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Modern Text Field
// Modern Text Field with Fixed Height
  Widget _buildModernProfileField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          // Fixed height container
          height: 56, // Standardized height for all fields
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              controller.text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

// Modern Button with Micro-interactions
  Widget _buildModernButton({
    required IconData icon,
    required String label,
    required Color color,
    bool isDestructive = false,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
              isDestructive ? color.withOpacity(0.1) : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isDestructive ? color.withOpacity(0.3) : color.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            splashColor: color.withOpacity(0.2),
            highlightColor: color.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: const Color.fromARGB(255, 168, 213, 249)),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
