import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:snowplow/Animation.dart';
import 'package:snowplow/user/Bid%20request/pendingrequest.dart';
import 'package:snowplow/user/bottomnav.dart';
import 'package:snowplow/user/homepage.dart';

class Recievebid extends StatefulWidget {
  final String? requestid;
  const Recievebid({super.key, required this.requestid});

  @override
  State<Recievebid> createState() => _RecievebidState();
}

class _RecievebidState extends State<Recievebid> {
  String? id;
  String? bidId;
  List<dynamic> receivedBids = [];
  bool isLoading = true;
  bool isAcepted = false;

  // Modern Color Palette
  final Color primaryColor = const Color.fromARGB(255, 213, 240, 245);
  final Color secondaryColor = const Color.fromARGB(255, 25, 118, 210);
  final Color accentColor = const Color.fromARGB(255, 255, 82, 82);
  final Color backgroundColor = Color.fromARGB(255, 213, 240, 245);
  final Color textPrimary = const Color(0xFF212529);
  final Color textSecondary = const Color(0xFF6C757D);

  @override
  void initState() {
    super.initState();
    id = widget.requestid;
    print("userinte id is $id");
    getRequest();
  }

  // method for get request..

  Future<void> getRequest() async {
    try {
      String apiUrl = 'https://snowplow.celiums.com/api/bids/bidlist';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"bid_request_id": id, "api_mode": "test"}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> requestList = responseData['data'] ?? [];
        if (requestList.isNotEmpty) {
          List<dynamic> fetchdata = requestList.map((request) {
            final status = request["status"] as String? ?? "pending";
            return {
              "requestId": request["bid_request_id"],
              "bid_id": request["bid_id"],
              "agency_id": request["agency_id"],
              "price": request["price"],
              "comments": request["comments"],
              "created": request["created"],
              "status": status,
              "is_accepted": status.toLowerCase() == "accepted",
            };
          }).toList();

          setState(() {
            receivedBids = fetchdata;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> acceptBid(String bidid) async {
    print("called accept bid");
    print("bid is is $bidid");
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse("https://snowplow.celiums.com/api/bids/accept"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"bid_id": bidid, "api_mode": "test"}),
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Bid Accepted Successfully!", true); 
        await getRequest();
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Bottomnavbar()),
          );
        });
      } else {
        showCustomSnackBar("Failed to Accept Bid", false);
      }
    } catch (e) {
      showCustomSnackBar("Error Occurred", false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showCustomSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      appBar: _buildAppBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "Received Bid Details",
        style: GoogleFonts.raleway(
          fontWeight: FontWeight.w600,
          color: textSecondary,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 213, 240, 245),
      iconTheme: IconThemeData(color: textPrimary),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           SnowLoader(),
            const SizedBox(height: 20),
            Text(
              "Loading bids...",
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (receivedBids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_neutral_outlined,
              size: 72,
              color: const Color.fromARGB(255, 119, 193, 218),
            ),
            const SizedBox(height: 24),
            Text(
              "Sorry...This bid is not seen by any companies,please wait untill they send a bid",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 119, 193, 218),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "When companies sebd bids, they'll appear here",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: receivedBids.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final bid = receivedBids[index];
        final formattedDate = bid["created"] != null
            ? DateTime.parse(bid["created"]).toLocal().toString().split(' ')[0]
            : "N/A";

        return _buildBidItem(bid, formattedDate);
      },
    );
  }
// ---------------------------------------------------------------------------------------------------------------

// checking already accepted the bid or not//

// -----------------------------------------------------------------------------------------------------------------
  Widget _buildBidItem(Map<String, dynamic> bid, String formattedDate) {
    final bool alreadyAccepted = bid["is_accepted"] == true;
    print("Bid ${bid["bid_id"]} is accepted? ${bid["is_accepted"]}");
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with bid ID and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "BID #${bid["bid_id"] ?? "N/A"}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: alreadyAccepted
                      ? Colors.green.withOpacity(0.15)
                      : primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alreadyAccepted ? "ACCEPTED" : "NEW",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: alreadyAccepted ? Colors.green : secondaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bid details in a modern grid layout
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildDetailCell(
                Icons.attach_money,
                "Bid Amount",
                "\$${bid["price"] ?? "N/A"}",
                secondaryColor,
              ),
              _buildDetailCell(
                Icons.business,
                "Agency ID",
                bid["agency_id"] ?? "N/A",
                secondaryColor,
              ),
              _buildDetailCell(
                Icons.calendar_today,
                "Submitted On",
                formattedDate,
                secondaryColor,
              ),
              _buildDetailCell(
                Icons.rate_review,
                "Status",
                bid["status"]?.toString().toUpperCase() ?? "N/A",
                secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Comments section
          if (bid["comments"]?.isNotEmpty == true) ...[
            _buildDetailRow(
              Icons.comment,
              "Comments",
              bid["comments"],
              secondaryColor,
            ),
            const SizedBox(height: 20),
          ],

          alreadyAccepted
              ? Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      "This bid has already been accepted",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )
              :
              // Action buttons
              Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  Bidpending()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentColor,
                          side: BorderSide(color: accentColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Ignore",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showConfirmationDialog(bid["bid_id"]);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "ACCEPT",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildDetailCell(
      IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showConfirmationDialog(String bidId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 32,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Accept This Bid?",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You're about to accept bid  This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 23, 252, 23),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                              color: const Color.fromARGB(255, 239, 12, 12)),
                        ),
                        child: Text(
                          "CANCEL",
                          style: GoogleFonts.raleway(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          acceptBid(bidId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "CONFIRM",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
