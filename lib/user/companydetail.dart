import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/user/Company%20Request/companyrequest.dart';
import 'package:http/http.dart' as http;
import 'package:snowplow/user/Company%20Request/showdirect.dart';
import 'package:snowplow/user/homepage.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> selectedcompany;

  const CompanyDetailScreen({super.key, required this.selectedcompany});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  List<dynamic> requestdata = [];
  String? companyid;
  String? companyname;
  bool isLoading = false;
  String? userId;
  @override
  void initState() {
    super.initState();
    companyid = widget.selectedcompany['id'];
    companyname = widget.selectedcompany['name'];
    print("companyid is $companyid, companyname is $companyname");

    _getrequest();
  }

  Future<void> _getrequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (companyid == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      String apiUrl = 'https://snowplow.celiums.com/api/requests/list';

      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "agency_id": companyid,
            "customer_id": userId,
            "per_page": "10",
            "page": "0",
            "api_mode": "test"
          }));

      if (response.statusCode == 200) {
        print("🔁 Response Code: ${response.statusCode}");
        print("📦 Response Body: ${response.body}");
        final responseData = jsonDecode(response.body);
        List<dynamic> requestlist = responseData['data'];
        print(requestlist);

        if (requestlist.isNotEmpty) {
          List<dynamic> singlerequest = requestlist.map((request) {
            final status = request["status"] as String? ?? "1";
            return {
              "requestId": request["request_id"],
              "created": request["created"],
              "urgency": request["urgency_level"] ?? "Not specified",
              "preferred_time": request["preferred_time"] ?? "Not specified",
              "preferred_date": request["preferred_date"] ?? "Not specified",
              "service_area": request["service_area"] ?? "Not specified",
              "image": request["image"]?.toString(),
              "status": request["status"],
              "is_accepted": status.toLowerCase() == "0",
            };
          }).toList();
          print("singlerequest$singlerequest");

          setState(() {
            requestdata = singlerequest.reversed.toList();

            isLoading = false;
          });
        } else {
          setState(() {
            requestdata = [];
            isLoading = false;
          });
        }
      } else {
        setState(
          () => isLoading = false,
        );
        print("❌ Failed to load request. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("🔥 Error fetching agencies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: RefreshIndicator(
        onRefresh: _getrequest,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 80,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF3A7BD5)),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  companyname!,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3A7BD5),
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFF1F7FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildInfoSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildRequestButtons(context),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE6F0FF), Color(0xFFD4E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child:
                const Icon(Icons.snowing, size: 36, color: Color(0xFF3A7BD5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyname!,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Certified Snow Services",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blueGrey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.location_on_outlined, "Service Area",
              widget.selectedcompany['address']),
          const Divider(height: 24, thickness: 1, color: Color(0xFFEDF2F7)),
          _buildInfoTile(Icons.email_outlined, "Email Address",
              widget.selectedcompany['email']),
          const Divider(height: 24, thickness: 1, color: Color(0xFFEDF2F7)),
          _buildInfoTile(Icons.phone_outlined, "Contact Number",
              widget.selectedcompany['contact']),
          const Divider(height: 24, thickness: 1, color: Color(0xFFEDF2F7)),
          _buildInfoTile(Icons.access_time_outlined, "Business Hours",
              "Mon-Fri: 6AM - 10PM"),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF3A7BD5), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blueGrey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ───────── Schedule button (your original) ─────────
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A7BD5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 4,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Companydirect(
                  selectedAgency: companyname!,
                  companyId: companyid!,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.snowmobile, size: 22),
              const SizedBox(width: 12),
              Text(
                "Schedule Snow Removal",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ───────── NEW: View‑my‑requests button ─────────
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3A7BD5),
            side: const BorderSide(color: Color(0xFF3A7BD5), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.list_alt, size: 22),
              const SizedBox(width: 8),
              Text(
                "View All Company Requests",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
