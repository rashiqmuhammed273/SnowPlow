import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowplow/user/companyrequest.dart';
import 'package:http/http.dart' as http;

class CompanyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> selectedcompany;
  final String? agencyid;

  const CompanyDetailScreen(
      {super.key, required this.selectedcompany, required this.agencyid});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  List<dynamic> requestdata = [];
  String? companyId;
  String? companyname;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    companyId = widget.selectedcompany['id'];
    companyname = widget.selectedcompany['name'];

    _getrequest();
  }

  Future<void> _getrequest() async {
    if (companyId == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      String apiUrl = 'https://snowplow.celiums.com/api/bids/requests';

      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({"agency_id": companyId, "api_mode": "test"}));

      print("🔁 Response Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> requestlist = responseData['data'];
        print(requestlist);

        if (requestlist.isNotEmpty) {
          List<dynamic> singlerequest = requestlist.map((request) {
            return {
              "requestId": request["request_id"],
              "created": request["created"],
              "urgency": request["urgency_level"] ?? "Not specified",
              "preferred_time": request["preferred_time"] ?? "Not specified",
              "preferred_date": request["preferred_date"] ?? "Not specified",
              "service_street": request["service_street"] ?? "Not specified",
              "image": request["image"]?.toString(),
              "status": request["status"],
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  Text(
                    'Service Requests',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A7BD5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : requestdata.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(Icons.inbox_rounded,
                                      size: 48,
                                      color: Colors.blueGrey.shade200),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No requests found",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: requestdata.length,
                              itemBuilder: (context, index) {
                                final request = requestdata[index];
                                return _buildRequestCard(request);
                              },
                            ),
                  // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildRequestButton(context),
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

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF3A7BD5)),
                const SizedBox(width: 8),
                Text(
                  "Request ID: ${request['requestId']}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request["status"] ?? "Unknown",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "${request['preferred_date']} at ${request['preferred_time']}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request['service_street'] ?? "No street provided",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            if (request['image'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    request['image'],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Image failed to load'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A7BD5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Companydirect(
                selectedAgency: companyname!,
                companyId: widget.selectedcompany['id'],
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.snowmobile, size: 22),
            const SizedBox(width: 12),
            Text(
              "Schedule Snow Removal",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
