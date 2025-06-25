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
  TextEditingController addressController = TextEditingController();
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
    String url = "https://snowplow.celiums.com/api/profile/details";

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
              addressController.text = userData['customer_address'] ?? "";
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

    String url =
        "https://firestore.googleapis.com/v1/projects/snow-plow-d24c0/databases/(default)/documents/users/$userId";

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 233, 245),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 169, 232, 243),
        title: Text(
          nameController.text.isNotEmpty ? nameController.text : "My Profile",
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    child: Icon(Icons.person_2_rounded),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileField("Name", nameController),
                  _buildProfileField("Contact", contactController),
                  _buildProfileField("Address", addressController),
                  _buildProfileField("Email", emailController),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, "/editProfile");
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: Text("Edit Profile",
                        style: GoogleFonts.poppins(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: showDeleteConfirmationDialog,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: Text("Delete Profile",
                        style: GoogleFonts.poppins(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94E77),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: showlogoutDialogue,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text("Logout",
                        style: GoogleFonts.poppins(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B8794),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
