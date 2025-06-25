
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class Directrequest extends StatefulWidget {
  const Directrequest({super.key});

  @override
  State<Directrequest> createState() => _DirectrequestState();
}

class _DirectrequestState extends State<Directrequest> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  Future<String?> getCompanyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? companyId = prefs.getString("agencyid");
    print("Stored Company ID: $companyId");

    return companyId;
  }

  @override
  void initState() {
    super.initState();
    getCompanyId().then((companyId) {
      if (companyId != null) {
        print("Company ID found: $companyId");
        fetchRequests(companyId); // Pass the actual companyId
      } else {
        print("Company ID not found");
      }
    });
  }

  Future<void> fetchRequests(String companyId) async {
    String firebaseUrl =
        "https://firestore.googleapis.com/v1/projects/snowplow-3163e/databases/(default)/documents/Directrequest";
      
    try {
      final response = await http.get(Uri.parse(firebaseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Firestore returned ${data["documents"]?.length ?? 0} documents");
        print("Looking for companyId: $companyId");

        for (var doc in data["documents"] ?? []) {
          print("Raw Document: ${jsonEncode(doc)}");
        }

        setState(() {
          final List docs = data["documents"] ?? [];

          requests = docs
              .map<Map<String, dynamic>>((doc) {
                final fields = doc["fields"] ?? {};
                return {
                  "id": doc["name"].split("/").last,
                  "company_id":
                      fields["selected_company"]?["stringValue"] ?? "",
                  "area": fields["area_type"]?["stringValue"] ?? "N/A",
                  "location": fields["location"]?["stringValue"] ?? "N/A",
                  "type": fields["service_type"]?["stringValue"] ?? "N/A",
                  "date": fields["preferred_date"]?["stringValue"] ?? "N/A",
                  "time": fields["preferred_time"]?["stringValue"] ?? "N/A",
                  "status": fields["status"]?["stringValue"] ?? "pending",
                };
              })
              .where((request) =>
                  request["company_id"].toString().toLowerCase() ==
                  companyId.toLowerCase())
              .toList();

          isLoading = false;
        });
      } else {
        print("Error: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: _buildLoadingShimmer())
          : requests.isEmpty
              ? Center(child: Text("No requests found"))
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return GestureDetector(
                      onTap: () {
                        // Future use for request details
                      },
                      child: Card(
                        color: Color.fromARGB(255, 160, 200, 236),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("🛠 ${request["type"]}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              SizedBox(height: 4),
                              Text("📍 ${request["area"]}",
                                  style: TextStyle(fontSize: 14)),
                              Text("📅 ${request["date"]} ⏰ ${request["time"]}",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
  
Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.all(12),
        child: Shimmer(
          color: const Color.fromARGB(255, 101, 174, 230),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
}
}
