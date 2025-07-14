import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String UserId;
  const ProfileScreen({super.key, required this.UserId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      fetchProfileData();
    }
  }

  Future<void> fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('apiKey');
    String? customerId = prefs.getString('userId');

    if (customerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login again")),
        );
      }
      return;
    }
    String url ="https://snowplow.celiums.com/api/profile/details";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token.toString(),
          'api_mode': 'test',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'api_mode': 'test',
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if ((data['status'] == 1 || data['status'] == 'success') &&
            data['data'] != null) {
          var userData = data['data'];
          if (mounted) {
            setState(() {
              nameController.text = userData['customer_name'] ?? "";
              emailController.text = userData['customer_email'] ?? "";
              contactController.text = userData['customer_phone'] ?? "";
              locationcontroller.text = userData['customer_country'] ?? "";
            });
            print("TOKEN IS $token");
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(data['message'] ?? "Failed to fetch profile data")),
            );
          }
        }
      } else {
        throw Exception("Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading profile: $e")),
        );
      }
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
    await prefs.remove("userId");
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
    if (userId == null) return;

    String url = "";

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove("userId");
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        throw Exception("Failed to delete company profile");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  @override
  Widget build( context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), // Soft blue background
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Elegant Profile Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Header with subtle gradient
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.shade50,
                                Colors.blue.shade100.withOpacity(0.3),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 20,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.1),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      "assets/man.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
                          child: Column(
                            children: [
                              // Profile Title
                              Text(
                                "PROFILE INFORMATION",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Elegant Info Items
                              _buildElegantInfoItem(Icons.person_outline,
                                  "Full Name", nameController.text),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                    height: 1, color: Color(0xFFEEF5FD)),
                              ),
                              _buildElegantInfoItem(Icons.email_outlined,
                                  "Email Address", emailController.text),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                    height: 1, color: Color(0xFFEEF5FD)),
                              ),
                              _buildElegantInfoItem(Icons.phone_iphone,
                                  "Contact Number", contactController.text),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                    height: 1, color: Color(0xFFEEF5FD)),
                              ),

                              const SizedBox(height: 32),

                              // Sophisticated Action Buttons
                              _buildElegantButton(
                                icon: Icons.edit_document,
                                label: "Edit Profile",
                                color: Colors.blue.shade700,
                                onPressed: () => Navigator.pushNamed(
                                    context, "/editProfile"),
                              ),
                              const SizedBox(height: 12),
                              _buildElegantButton(
                                icon: Icons.delete_outline,
                                label: "Delete Account",
                                color: Colors.red.shade400,
                                onPressed: showDeleteConfirmationDialog,
                              ),
                              const SizedBox(height: 12),
                              _buildElegantButton(
                                icon: Icons.logout,
                                label: "Sign Out",
                                color: Colors.blueGrey.shade600,
                                onPressed: showlogoutDialogue,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildElegantInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey.shade500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildElegantButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.05),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: color.withOpacity(0.2),
              )),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  } 
}
