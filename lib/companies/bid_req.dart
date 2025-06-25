import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snowplow/companies/showbid.dart';

class Bidrequest extends StatefulWidget {
  const Bidrequest({super.key});

  @override
  State<Bidrequest> createState() => _BidrequestState();
}

class _BidrequestState extends State<Bidrequest> {
  List<dynamic> requests = [];
  bool isLoading = true;
  bool isAccepted = false;
  String? userid;
  String? username;
  bool isProfileLoaded = false;
  Map<String, String> userNamesMap = {};

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchUserNameFor(String customerId) async {
    String url = "https://snowplow.celiums.com/api/profile/details";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
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
          setState(() {
            userNamesMap[customerId] = userData['customer_name'] ?? 'Unknown';
          });
        }
      }
    } catch (e) {
      print("Error fetching username for $customerId: $e");
      setState(() {
        userNamesMap[customerId] = 'Unknown';
      });
    }
  }

  Future<void> fetchRequests() async {
    String apiUrl = "https://snowplow.celiums.com/api/bids/agentrequests";

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body:
              jsonEncode({"per_page": "300", "page": "0", "api_mode": "test"}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> biddetail = data["data"];
        // print("biddetails $biddetail");

        if (biddetail.isNotEmpty) {
          List<dynamic> requestlist = biddetail.map((item) {
            return {
              "requestid": item["bid_request_id"] ?? "unknown",
              "userid": item["customer_id"] ?? "unknown",
              "street": item["service_street"] ?? "unknown",
              "latitude": item["service_latitude"] ?? "unknown",
              "longitude": item["service_longitude"] ?? "unknown",
              "type": item["service_type"] ?? "unknown",
              "area": item["service_area"] ?? "unknown",
              "time": item["preferred_time"] ?? "unknown",
              "date": item["preferred_date"] ?? "unknown",
              "urgency": item["urgency_level"] ?? "unknown",
              "image": item["image"] ?? "unknown",
              "created_time": item["created"] ?? "unknown",
            };
          }).toList();

          setState(() {
            isLoading = false;
            requests = requestlist;
          });
          ////user id using lambda//////
          final userIds = requestlist
              .map((item) => item['userid'])
              .toSet(); // Unique user IDs

          await Future.wait(userIds.map((id) => fetchUserNameFor(id)));

          setState(() {
            isProfileLoaded = true;
          });
        }
      } else {
        print("Error: ${response.body}");
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print("Exception: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  ///set timeago///
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
    backgroundColor: Colors.blueGrey[50],
    body: (!isProfileLoaded || isLoading)
        ? _buildSnowLoadingShimmer()
        : requests.isEmpty
            ? _buildSnowEmptyState()
            : RefreshIndicator(
                onRefresh: fetchRequests,
                child: Column(
                  children: [
                    // Header with snow icon
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.snowing, color: Colors.blue[800], size: 28),
                          const SizedBox(width: 8),
                          Text(
                            "Plow Requests (${requests.length})",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Request cards
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          final timeAgo = getTimeAgo(DateTime.parse(request["created_time"]));
                          return _buildSnowPlowCard(request, timeAgo, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
  );
}

Widget _buildSnowPlowCard(Map<String, dynamic> request, String timeAgo, int index) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Showbid(biddetails: request),
          ),
        );
        fetchRequests();
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: Colors.blue[800]),
                    const SizedBox(width: 6),
                    Text(
                      userNamesMap[request["userid"]] ?? "New Client",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 12),
            
            // Snowplow details
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildSnowDetail(Icons.location_on, request["street"]),
                _buildSnowDetail(Icons.calendar_today, request["date"]),
                _buildSnowDetail(Icons.access_time, request["time"]),
                _buildSnowPriorityBadge(request["priority"] ?? "standard"),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSnowDetail(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: Colors.blue[700]),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.blueGrey[800],
        ),
      ),
    ],
  );
}

Widget _buildSnowPriorityBadge(String priority) {
  Color color;
  String label;
  
  switch (priority.toLowerCase()) {
    case "emergency":
      color = Colors.red[600]!;
      label = "❄️ Emergency";
      break;
    case "high":
      color = Colors.orange[600]!;
      label = "High Priority";
      break;
    case "standard":
    default:
      color = Colors.blue[600]!;
      label = "Standard";
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3),
    ),
    
  ),
  
  child: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        color: color,
        fontWeight: FontWeight.w500,
      ),
    ),);
}

Widget _buildSnowEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.snowing, size: 64, color: Colors.blue[200]),
        const SizedBox(height: 16),
        Text(
          "No Plow Requests",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "When it snows, requests will appear here",
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSnowLoadingShimmer() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (context, index) => Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    ),
  );
}}