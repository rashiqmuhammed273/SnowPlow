

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/Animation.dart';
import 'package:snowplow/companies/Direct Data/directdetails.dart';
import 'package:snowplow/widgets/images.dart';

/// Agency‑side screen that now mirrors the user‑side UI used in `Directreqscreen`.
/// Status badges (Accepted / Pending), time‑ago badge, and detail rows all
/// follow the same style so both screens look consistent.
class Directrequest extends StatefulWidget {
  const Directrequest({super.key});

  @override
  State<Directrequest> createState() => _DirectrequestState();
}

class _DirectrequestState extends State<Directrequest> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;
  String selectedFilter = 'all'; 

  // customer_id → username map to avoid multiple network hits
  final Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  /* ────────────────────────────────────────────────────────────────────────────
   * Networking
   * ───────────────────────────────────────────────────────────────────────────*/

  Future<void> _fetchRequests() async {
    if (mounted) setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('agency_id');

    if (companyId == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('https://snowplow.celiums.com/api/requests/agencyrequests'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'agency_id': companyId,
          "per_page": "20",
          "page": "0",
          'api_mode': 'test',
        }),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body)['data'];

        final transformed = data
            .map<Map<String, dynamic>>((item) {
              final status = (item['status']).toString();
              return {
                'requestId': item['request_id'] ?? 'unknown',
                'customerId': item['customer_id'] ?? 'unknown',
                'street': item['service_street'] ?? 'unknown',
                'area': item['service_area'] ?? 'unknown',
                'preferredTime': item['preferred_time'] ?? 'unknown',
                'preferredDate': item['preferred_date'] ?? 'unknown',
                'urgency': item['urgency_level'] ?? 'standard',
                'image': item['image'],
                'created': item['created'],
                ' type': item["service_type"],
                'isAccepted': status == '0' ? true : false,

              };
            })
            .toList()
            .reversed
            .toList();

            

        // Fetch usernames in parallel (only unique ids)
        final userIds = transformed.map((e) => e['customerId']).toSet();
        await Future.wait(userIds.map((id) => _fetchUsername(id)));

        if (mounted) {
          setState(() {
            requests = transformed;
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUsername(String userId) async {
    if (_userNames.containsKey(userId)) return; // cached

    try {
      final res = await http.post(
        Uri.parse('https://snowplow.celiums.com/api/profile/details'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'customer_id': userId, 'api_mode': 'test'}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final name = (data['data']?['customer_name'] ?? 'Unknown').toString();
        _userNames[userId] = name;
      }
    } catch (_) {
      _userNames[userId] = 'Unknown';
    }
  }

  /* ────────────────────────────────────────────────────────────────────────────
   * Helpers
   * ───────────────────────────────────────────────────────────────────────────*/

  String _timeAgo(String iso) {
    final created = DateTime.tryParse(iso) ?? DateTime.now();
    final diff = DateTime.now().difference(created);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('dd MMM yyyy').format(created);
  }

  Widget _placeholder() => const Center(
        // child: Imagealternate()
        child:Imagealternate()
      );

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 10, color: Colors.blueGrey[500])),
              Text(value,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey[800],
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  /* ────────────────────────────────────────────────────────────────────────────
   * UI
   * ───────────────────────────────────────────────────────────────────────────*/

  @override
  Widget build(BuildContext context) {
    final filteredList = requests.where((item) {
  if (selectedFilter == 'all') return true;
  if (selectedFilter == 'pending') return item['isAccepted'] == false;
  if (selectedFilter == 'accepted') return item['isAccepted'] == true;
  return true;
}).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: isLoading
          ? SnowLoader()
          : RefreshIndicator(
              onRefresh: _fetchRequests,
              child: requests.isEmpty
                  ? _emptyState()
                  :
                  // Count Summary
                  Column(children: [
                      _buildOverviewCard(),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final timeAgo = _timeAgo(item['created']);
                            final accepted = item['isAccepted'] as bool;
                            return Card(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 126, 179, 206),
                                  width: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              clipBehavior: Clip.antiAlias,
                              elevation: 8,
                              shadowColor:
                                  const Color.fromARGB(255, 12, 168, 246)
                                      .withOpacity(0.4),
                              child: Stack(
                                children: [
                                  // Card body identical to user‑side
                                  Material(
                                    color: Colors.white,
                                    child: InkWell(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DIrectDetails(
                                              requestdetails: item,
                                              Username: _userNames[
                                                  item['customerId']],
                                            ),
                                          ),
                                        );
                                        _fetchRequests();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            // STATUS + menu row
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
                                                    color: accepted
                                                        ? Colors.green
                                                            .withOpacity(0.15)
                                                        : Colors.orange
                                                            .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    accepted
                                                        ? 'Accepted'
                                                        : 'Pending',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: accepted
                                                          ? Colors.green
                                                          : Colors.orange,
                                                    ),
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: const Icon(Icons.delete,
                                                      size: 18),
                                                  onSelected: (value) {
                                                    _confirmDelete(
                                                        item["requestId"]);
                                                  },
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: 'delete',
                                                      child: Text('Delete'),
                                                    ),
                                                  
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            // uploaded badge
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
                                              child: Text('Uploaded $timeAgo',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors
                                                          .blueGrey[600])),
                                            ),
                                            const SizedBox(height: 4),
                                            // details row
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // thumbnail
                                                Container(
                                                  width: 70,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.blueGrey[100],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: item['image'] != null
                                                        ? Image.network(
                                                            item['image'],
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_,
                                                                    __, ___) =>
                                                                _placeholder(),
                                                          )
                                                        : isLoading
                                                            ? SnowLoader()
                                                            : _placeholder(),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // textual details
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _detailRow(
                                                          Icons.person,
                                                          'Client',
                                                          _userNames[item[
                                                                  'customerId']] ??
                                                              '---',
                                                          Colors.blue),
                                                      const SizedBox(height: 4),
                                                      _detailRow(
                                                          Icons.calendar_today,
                                                          'Date & Time',
                                                          '${item['preferredDate']} • ${item['preferredTime']}',
                                                          Colors.blue),
                                                      const SizedBox(height: 6),
                                                      _detailRow(
                                                          Icons.location_on,
                                                          'Location',
                                                          item['area'],
                                                          Colors.green),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Banner top‑left
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
                                      child: const Text('Direct Request',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
            ),
    );
  }
    Widget _buildOverviewCard() {
    int total = requests.length;
    int pending = requests.where((r) => !(r['isAccepted'] as bool)).length;
    int accepted = total - pending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
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
        height: 35,
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

  Future<void> _deleteRequest(String requestId) async {
    try {
      final response = await http.post(
        Uri.parse('https://snowplow.celiums.com/api/requests/delete'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"request_id": requestId, "api_mode": "test"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          requests.removeWhere((item) => item["requestId"] == requestId);
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

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.blueGrey[300]),
            const SizedBox(height: 12),
            Text('No direct requests',
                style: TextStyle(color: Colors.blueGrey[400])),
          ],
        ),
      );
      
}
