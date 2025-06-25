import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/user/recievebid.dart';

class Pendingrequest extends StatefulWidget {
  const Pendingrequest({super.key});

  @override
  State<Pendingrequest> createState() => _PendingrequestState();
}

class _PendingrequestState extends State<Pendingrequest> {
  @override
  void initState() {
    super.initState();
    getRequest();
  }

  bool isLoading = true;
  List<dynamic> requestdata = [];

  String? requestId;

  bool? isAcceptable = false;

////////////function for getting the requerst////////////
  Future<void> getRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('apiKey');

    if (userId == null) {
      print("❌ userId not found in SharedPreferences.");
      setState(() => isLoading = false);
      return;
    }

    try {
      String apiUrl = 'https://snowplow.celiums.com/api/bids/requests';

      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token.toString(),
            "Accept": "application/json",
          },
          body: jsonEncode({
            "customer_id": userId,
            "per_page": "10",
            "page": "0",
            "api_mode": "test"
          }));

      print("🔁 Response Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> requestlist = responseData['data'];

        print(requestlist);

        if (requestlist.isNotEmpty) {
          List<dynamic> singlerequest = requestlist.map((request) {
            final status = request["status"] as String? ?? "1";
            return {
              "requestId": request["bid_request_id"],
              "created": request["created"],
              "urgency": request["urgency_level"] ?? "Not specified",
              "preferred_time": request["preferred_time"] ?? "Not specified",
              "preferred_date": request["preferred_date"] ?? "Not specified",
              "service_street": request["service_street"] ?? "Not specified",
              "image": request["image"]?.toString(),
              "status": status,
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

  ////////methods for adding and delete requests///////

  void updateRequest(int index) {
    final request = requestdata[index];
    // For now, just show a simple dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Update Request"),
        content: Text(
            "Implement your update UI here for request created at ${request['created']}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _deleteRequest(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Confirmation"),
        content: const Text("Are you sure you want to delete this request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color.fromARGB(255, 52, 163, 253)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmdelete(index);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  ///method for time ago/////
  String getTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minute(s) ago";
    if (diff.inHours < 24) return "${diff.inHours} hour(s) ago";
    if (diff.inDays < 7) return "${diff.inDays} day(s) ago";
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              ),
            )
          : RefreshIndicator(
              onRefresh: getRequest,
              color: Colors.blueGrey,
              child: requestdata.isNotEmpty
                  ? Card(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: requestdata.length,
                        itemBuilder: (context, index) {
                          final item = requestdata[index];
                          final uploadedTime = DateTime.parse(item["created"]);
                          final timeAgo = getTimeAgo(uploadedTime);
                          final bool alreadyAccepted =
                              item["is_accepted"] == true;

                          print(requestId);
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Recievebid(requestid: item["requestId"]),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: alreadyAccepted
                                            ? Colors.green.withOpacity(0.15)
                                            : const Color.fromARGB(
                                                    255, 243, 103, 33)
                                                .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        alreadyAccepted
                                            ? "Accepted"
                                            : "pending",
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: alreadyAccepted
                                              ? Colors.green
                                              : Colors.orange,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    // Header with date and time ago
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[50],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "Uploaded $timeAgo",
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              color: Colors.blueGrey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'update') {
                                              updateRequest(index);
                                            } else if (value == 'delete') {
                                              _deleteRequest(index);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return [
                                              const PopupMenuItem(
                                                value: 'update',
                                                child: Text('Update'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                            ];
                                          },
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Content row with image and details
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Image container
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.blueGrey[100],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: item['image'] != null &&
                                                    item['image']
                                                        .toString()
                                                        .isNotEmpty
                                                ? Image.network(
                                                    item['image'],
                                                    width: 150,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        _buildPlaceholderIcon(),
                                                  )
                                                : _buildPlaceholderIcon(),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Details column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildDetailRow(
                                                Icons.bolt,
                                                "Urgency",
                                                item["urgency"],
                                                const Color.fromARGB(
                                                    255, 255, 98, 0),
                                              ),
                                              const SizedBox(height: 8),
                                              _buildDetailRow(
                                                  Icons.date_range_rounded,
                                                  "preferred date",
                                                  item["preferred_date"],
                                                  const Color.fromARGB(
                                                      255, 0, 104, 120)),
                                              const SizedBox(height: 8),
                                              _buildDetailRow(
                                                Icons.location_on,
                                                "Location",
                                                item["service_street"],
                                                Colors.green,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.blueGrey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No pending requests",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.blueGrey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.hide_image_outlined,
        size: 40,
        color: Colors.blueGrey[300],
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.blueGrey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.blueGrey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmdelete(int index) async {
    String? token = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('apiKey'));

    final apiUrl = "https://snowplow.celiums.com/api/bids/delete";
    try {
      final response = await http.delete(Uri.parse(apiUrl),
          headers: {
            "Authorization": token ?? "",
            "Accept": "application/json",
          },
          body: jsonEncode({"request_id": requestId, "api_mode": "test"}));

      if (response.statusCode == 200) {
        setState(() {
          requestdata.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Failed to delete request: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting request: $e")),
      );
    }
  }
}
