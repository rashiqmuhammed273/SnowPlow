import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:snowplow/Animation.dart';
import 'package:snowplow/companies/Bid%20data/biddetails.dart';
import 'package:snowplow/widgets/images.dart';

class Bidrequest extends StatefulWidget {
  const Bidrequest({super.key});

  @override
  State<Bidrequest> createState() => _BidrequestState();
}

class _BidrequestState extends State<Bidrequest> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;
  final Map<String, String> _userNames = {};
  String selectedFilter = 'all';
  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    if (mounted) setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('https://snowplow.celiums.com/api/bids/agentrequests'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'per_page': '10',
          'page': '0',
          'api_mode': 'test',
        }),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body)['data'];

        final transformed = data.map<Map<String, dynamic>>((item) {
          final status = (item['status'] ?? "1").toString();
          return {
            'requestId': item['bid_request_id'] ?? 'unknown',
            'customerId': item['customer_id'] ?? 'unknown',
            'street': item['service_street'] ?? 'unknown',
            'area': item['service_area'] ?? 'unknown',
            'preferredTime': item['preferred_time'] ?? 'unknown',
            'preferredDate': item['preferred_date'] ?? 'unknown',
            'urgency': item['urgency_level'] ?? 'standard',
            'image': item['image'],
            'created': item['created'],
            'type': item['service_type'],
            'isAccepted': status == '0' ? true : false,
          };
        }).toList();

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
    if (_userNames.containsKey(userId)) return;

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

  String _timeAgo(String iso) {
    final created = DateTime.tryParse(iso) ?? DateTime.now();
    final diff = DateTime.now().difference(created);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('dd MMM yyyy').format(created);
  }

  Widget _placeholder() => const Center(child: Imagealternate());

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

  @override
  @override
  Widget build(BuildContext context) {
    final filteredList = requests.where((item) {
      if (selectedFilter == 'all') return true;
      if (selectedFilter == 'pending') return item['isAccepted'] == false;
      if (selectedFilter == 'accepted') return item['isAccepted'] == true;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: isLoading
          ? SnowLoader()
          : RefreshIndicator(
              onRefresh: _fetchRequests,
              child: requests.isEmpty
                  ? _emptyState()
                  : Column(
                      children: [
                        _buildOverviewCard(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              final timeAgo = _timeAgo(item['created']);
                              final accepted = item['isAccepted'] as bool;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.blueAccent.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            Showbid(biddetails: item),
                                      ),
                                    );
                                    _fetchRequests();
                                  },
                                  borderRadius: BorderRadius.circular(18),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: item['image'] != null
                                              ? Image.network(
                                                  item['image'],
                                                  width: 75,
                                                  height: 75,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _placeholder(),
                                                )
                                              : _placeholder(),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: accepted
                                                          ? Colors.green
                                                              .withOpacity(0.12)
                                                          : Colors.orange
                                                              .withOpacity(
                                                                  0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      accepted
                                                          ? 'Accepted'
                                                          : 'Pending',
                                                      style: TextStyle(
                                                        color: accepted
                                                            ? Colors.green[700]
                                                            : Colors
                                                                .orange[800],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 11.5,
                                                      ),
                                                    ),
                                                  ),
                                                  PopupMenuButton<String>(
                                                    icon: const Icon(
                                                        Icons.more_vert,
                                                        size: 20),
                                                    onSelected: (value) {
                                                      if (value == 'delete') {
                                                        _confirmDelete(
                                                            item["requestId"]);
                                                      }
                                                    },
                                                    itemBuilder: (context) =>
                                                        const [
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text('Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text('Uploaded $timeAgo',
                                                  style: TextStyle(
                                                      fontSize: 11.2,
                                                      color: Colors
                                                          .blueGrey[500])),
                                              const SizedBox(height: 10),
                                              _detailRow(
                                                  Icons.person,
                                                  'Client',
                                                  _userNames[
                                                          item['customerId']] ??
                                                      '---',
                                                  Colors.blue),
                                              const SizedBox(height: 6),
                                              _detailRow(
                                                  Icons.calendar_today,
                                                  'Date & Time',
                                                  '${item['preferredDate']} • ${item['preferredTime']}',
                                                  Colors.indigo),
                                              const SizedBox(height: 6),
                                              _detailRow(
                                                  Icons.location_on,
                                                  'Location',
                                                  item['area'],
                                                  Colors.teal),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
        Uri.parse('https://snowplow.celiums.com/api/bids/delete'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"request_id": requestId, "api_mode": "test"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          requests.removeWhere((item) => item["requestId"] == requestId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request deleted successfully"),
            backgroundColor: Colors.green,
          ),
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

  Widget _buildOverviewCard() {
    int total = requests.length;
    int pending = requests.where((r) => !(r['isAccepted'] as bool)).length;

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

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.blueGrey[300]),
            const SizedBox(height: 12),
            Text('No bid requests',
                style: TextStyle(color: Colors.blueGrey[400])),
          ],
        ),
      );
}
