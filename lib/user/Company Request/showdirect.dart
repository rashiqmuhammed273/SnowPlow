import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/animation.dart';
import 'package:snowplow/user/Company%20Request/directrequest.dart';
import 'package:snowplow/user/Company%20Request/editrequest.dart';
import 'package:snowplow/widgets/images.dart';

class Directreqscreen extends StatefulWidget {
  const Directreqscreen({super.key});

  @override
  State<Directreqscreen> createState() => _DirectreqscreenState();
}

class _DirectreqscreenState extends State<Directreqscreen> {
  List<dynamic> requestdata = [];
  bool isLoading = false;
  String? userId;
  String? requestId;
  final Map<String, String> _agencyNames = {};

  String selectedFilter = 'all'; // all | pending | accepted

  @override
  void initState() {
    super.initState();
    _getrequest();
  }

  Future<void> _fetchAgencyName(String agencyId) async {
    if (_agencyNames.containsKey(agencyId)) return; // already cached

    try {
      final response = await http.post(
        Uri.parse('https://snowplow.celiums.com/api/agencies/details'),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
              'api_mode': 'test',
        },
        body: jsonEncode({"agency_id": agencyId, "api_mode": "test"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['data']["agency_name"];

        print("name of the company is $name");

        setState(() {
          _agencyNames[agencyId] = name;
        });
      } else {
        print('Failed to fetch agency name: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agency name: $e');
    }
  }

  Future<void> _getrequest() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    try {
      final response = await http.post(
        Uri.parse('https://snowplow.celiums.com/api/requests/list'),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "customer_id": userId,
          "per_page": "100",
          "page": "0",
          "api_mode": "test"
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> requestlist = responseData['data'];

        if (requestlist.isNotEmpty) {
          setState(() {
            requestdata = requestlist
                .map((request) {
                  final status = request["status"] as String? ?? "1";
                  return {
                    "requestId": request["request_id"],
                    "agency_id": request["agency_id"],
                    "created": request["created"],
                    "urgency": request["urgency_level"] ?? "Not specified",
                    "preferred_time":
                        request["preferred_time"] ?? "Not specified",
                    "preferred_date":
                        request["preferred_date"] ?? "Not specified",
                    "service_area": request["service_area"] ?? "Not specified",
                    "service_street":
                        request["service_street"] ?? "Not specified",
                    "image": request["image"]?.toString(),
                    "status": request["status"],
                    "is_accepted": status.toLowerCase() == "0",
                  };
                })
                .toList()
                .reversed
                .toList();
            isLoading = false;
          });
          // 👉 Fetch agency names here
          for (var item in requestdata) {
            final agencyId = item["agency_id"];
            if (agencyId != null) {
              _fetchAgencyName(agencyId);
            }
          }
        } else {
          setState(() {
            requestdata = [];
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String getTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  void _navigateToRequestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Directrequestpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = requestdata.where((item) {
      if (selectedFilter == 'all') return true;
      if (selectedFilter == 'pending') return item['is_accepted'] == false;
      if (selectedFilter == 'accepted') return item['is_accepted'] == true;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToRequestPage,
        backgroundColor: const Color.fromARGB(255, 119, 185, 243),
        tooltip: 'Make a Request',
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: 
          SnowLoader())
          : RefreshIndicator(
              onRefresh: _getrequest,
              child: requestdata.isNotEmpty
                  ? Column(children: [
                      _buildOverviewCard(),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final uploadedTime =
                                DateTime.parse(item["created"]);
                            final timeAgo = getTimeAgo(uploadedTime);
                            final bool alreadyAccepted = item["is_accepted"];

                            return Dismissible(
                              key: ValueKey(item["requestId"]),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red.shade400,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await _confirmDelete(item["requestId"]);
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 126, 179, 206),
                                    width: 0.6,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                clipBehavior: Clip.antiAlias,
                                elevation: 8,
                                shadowColor: Color.fromARGB(255, 12, 168, 246)
                                    .withOpacity(0.4),
                                child: Stack(
                                  children: [
                                    // Card Body
                                    Material(
                                      color: Colors.white,
                                      child: InkWell(
                                        onTap: () {
                                          // navigate
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            // crossAxisAlignment:
                                            //     CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: alreadyAccepted
                                                          ? Colors.green
                                                              .withOpacity(0.15)
                                                          : Colors.orange
                                                              .withOpacity(
                                                                  0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      alreadyAccepted
                                                          ? "Accepted"
                                                          : "Pending",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: alreadyAccepted
                                                            ? Colors.green
                                                            : Colors.orange,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        PopupMenuButton<String>(
                                                      icon: const Icon(
                                                          Icons.more_horiz,
                                                          size: 18),
                                                      onSelected: (value) {
                                                        if (value == 'delete') {
                                                          _confirmDelete(item[
                                                              "requestId"]);
                                                        } else {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Editrequest(
                                                                  previousdata:
                                                                      item,
                                                                  companyId: item[
                                                                      "agency_id"],
                                                                  companyname:
                                                                      _agencyNames[
                                                                          item[
                                                                              "agency_id"]],
                                                                ),
                                                              ));
                                                        }
                                                      },
                                                      itemBuilder: (context) =>
                                                          [
                                                        PopupMenuItem(
                                                          value: 'delete',
                                                          child: Text('Delete'),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 'edit',
                                                          child: Text("Edit"),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[50],
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  "Uploaded $timeAgo",
                                                  style: GoogleFonts.raleway(
                                                    fontSize: 11,
                                                    color: Colors.blueGrey[600],
                                                  ),
                                                ),
                                              ),
                                              // Status badge

                                              // Row with time + menu

                                              const SizedBox(height: 8),

                                              // Content row
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Image container
                                                  Container(
                                                    width: 90,
                                                    height: 90,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          Colors.blueGrey[100],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: item['image'] !=
                                                              null
                                                          ? Image.network(
                                                              item['image'],
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  _buildPlaceholderIcon(),
                                                            )
                                                          : isLoading
                                                              ? SnowLoader()
                                                              : _buildPlaceholderIcon(),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),

                                                  // Details column
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildDetailRow(
                                                          Icons.business,
                                                          "Company",
                                                          _agencyNames[item[
                                                                  "agency_id"]] ??
                                                              "Loading...",
                                                          const Color.fromARGB(
                                                              255,
                                                              59,
                                                              105,
                                                              255),
                                                        ),
                                                        _buildDetailRow(
                                                          Icons.bolt,
                                                          "Urgency",
                                                          item["urgency"],
                                                          Colors.orange,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        _buildDetailRow(
                                                          Icons.calendar_today,
                                                          "Date & Time",
                                                          "${item["preferred_date"]} • ${item["preferred_time"]}",
                                                          Colors.blue,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        _buildDetailRow(
                                                          Icons.location_on,
                                                          "Location",
                                                          item["service_area"],
                                                          Colors.green,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 🔻 Banner on top-left INSIDE card
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        width: 100,
                                        height: 37,
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(205, 66, 142, 241),
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(32),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'direct Request',
                                          style: GoogleFonts.raleway(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ])
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 48,
                            color: Colors.blueGrey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No direct requests",
                            style: GoogleFonts.poppins(
                              color: Colors.blueGrey[400],
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
      child: Imagealternate()
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: Colors.blueGrey[500],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.blueGrey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _deleteRequest(String requestId) async {
    try {
      final response = await http.post(
        Uri.parse('https://snowplow.celiums.com/api/requests/delete'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"request_id": requestId, "api_mode": "test"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          requestdata.removeWhere((item) => item["requestId"] == requestId);
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

  Future<bool?> _confirmDelete(String requestId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete request?'),
          content: const Text(
            'This action cannot be undone. Do you really want to delete this request?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteRequest(requestId);
    }

    return confirmed; // This is what `Dismissible` needs
  }

  Widget _buildOverviewCard() {
    int total = requestdata.length;
    int pending = requestdata.where((r) => !(r['is_accepted'] as bool)).length;
    int accepted = total - pending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Counts Row
            Row(
              children: [
                _buildStatItem("Total Requests", total, Colors.blue),
                _divider(),
                _buildStatItem("Pending", pending,
                    const Color.fromARGB(255, 226, 135, 78)),
                _divider(),
                _buildStatItem("Accepted", accepted, Colors.green),
              ],
            ),

            const SizedBox(height: 24),

            /// Filter Buttons
            Row(
              children: [
                _buildFilterButton("All Requests", 'all'),
                const SizedBox(width: 8),
                _buildFilterButton("Pending", 'pending'),
                const SizedBox(width: 8),
                _buildFilterButton("Completed", 'accepted'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$value",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.raleway(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = selectedFilter == value;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6D9EFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6D9EFF) : Colors.grey.shade300,
            width: 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6D9EFF).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => selectedFilter = value),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
