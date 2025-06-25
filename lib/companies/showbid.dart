import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/companies/bottmnav.dart';

class Showbid extends StatefulWidget {
  final Map<String, dynamic> biddetails;
  const Showbid({super.key, required this.biddetails});

  @override
  State<Showbid> createState() => _ShowbidtState();
}

class _ShowbidtState extends State<Showbid> {
  Map<String, dynamic>? request;
  bool isLoading = false;
  final TextEditingController _bidController = TextEditingController();
  final TextEditingController _comments = TextEditingController();
  String? agencyid;
  bool bidAlreadyPlaced = false;

  @override
  void initState() {
    super.initState();
    request = widget.biddetails;
    _initialize();
  }

  Future<void> _initialize() async {
    await _getagencyid();
    await _showbid(); // Now it waits until agencyid is ready
  }

  Future<void> _getagencyid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    agencyid = prefs.getString("agencyid");
    print("getted id frrrrom $agencyid");
  }

  Future<void> _showbid() async {
    final birequestid = request!["requestid"];
    print("bid id is $birequestid");
    try {
      final response = await http.post(
        Uri.parse("https://snowplow.celiums.com/api/bids/viewbid"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "bid_request_id": birequestid,
          "agency_id": agencyid,
          "api_mode": "test"
        }),
      );
      final resposnsedata = jsonDecode(response.body);
      final data = resposnsedata['data'];
      if (response.statusCode == 200 &&
          resposnsedata['status'] == 1 &&
          data != null) {
        setState(() {
          _bidController.text = (data['price'] ?? '').toString();
          _comments.text = (data['comments'] ?? '').toString();
          print("the bid amount is ${_bidController.text}");
          bidAlreadyPlaced = true;
        });
      } else {
        setState(() {
          bidAlreadyPlaced = false;
        });
        // Show error message
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("fetch bid: ${response.body}"),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Error submitting bid: $e");
    }
  }

  Future<void> _sendBid() async {
    print("sendbid called");

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("https://snowplow.celiums.com/api/bids/createbid"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "bid_request_id": request!["requestid"],
          "agency_id": agencyid ?? "",
          "price": _bidController.text,
          "comments": _comments.text,
          "api_mode": "test"
        }),
      );
      final resposnsedata = jsonDecode(response.body);
      print("Response: $resposnsedata");
      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Bid submitted successfully!"),
          backgroundColor: Colors.green,
        ));

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Cmpnavabar()),
          );
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit bid: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Error submitting bid: $e");
    }
  }

////////////////ui section//////////////
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Service Request",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : request == null
                ? Center(
                    child:
                        Text("Request not found", style: textTheme.bodyLarge))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserSection(GoogleFonts.labradaTextTheme()),
                        const SizedBox(height: 16),
                        _buildRequestDetailsCard(
                            GoogleFonts.ralewayTextTheme()),
                        const SizedBox(height: 24),
                        _buildImageSection(),
                        const SizedBox(height: 24),
                        bidAlreadyPlaced
                            ? _buildBidConfirmation(
                                ColorScheme.fromSeed(seedColor: Colors.blue),
                                GoogleFonts.ralewayTextTheme())
                            : _buildBidForm(
                                ColorScheme.fromSeed(seedColor: Colors.blue),
                                GoogleFonts.ralewayTextTheme())
                      ],
                    ),
                  ),
      ),
    );
  }

//////////// ui helping methods////////////
  Widget _buildUserSection(TextTheme textTheme) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("requested by",
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 20,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text((request!["userid"] ?? "Unknown").toString())
                // style: GoogleFonts.poppins(
                //     fontSize: 14, fontWeight: FontWeight.w500))
              ],
            ),
          ],
        ),
      ),
    );
  }

/////////card/////////
  Widget _buildRequestDetailsCard(TextTheme textTheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Request Details",
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildDetailItem(Icons.numbers_rounded, "Bid number",
                request!["requestid"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.location_on, "Location",
                request!["area"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.access_time, "Uploaded",
                request!["created_time"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.calendar_today, "Preferred Date",
                request!["date"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.schedule, "Preferred Time",
                request!["time"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.place, "Service Area",
                request!["type"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.build, "Service Type",
                request!["type"]?.toString() ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: primaryColor)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

/////////////image/////////////
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Uploaded Image",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        request!["image"] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  request!["image"],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                ),
              )
            : _buildImagePlaceholder(),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text("No image available",
                style:
                    GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBidForm(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Place Your Bid",
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: _bidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Bid Amount",
                prefixIcon: const Icon(Icons.attach_money),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comments,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Comments (Optional)",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _sendBid,
                    child: const Text("Submit Bid"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBidConfirmation(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text("Bid Placed",
                    style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
                Icons.attach_money,
                "Bid Amount",
                _bidController.text.isNotEmpty
                    ? _bidController.text
                    : "Not available"),
            _buildDetailItem(Icons.comment, "comment",
                _comments.text.isNotEmpty ? _comments.text : "Not available"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton(
                  onPressed: bidAlreadyPlaced == true
                      ? null
                      : _sendBid, // Disable when loading
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Bid"),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
