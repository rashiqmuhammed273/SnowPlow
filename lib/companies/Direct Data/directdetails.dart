import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snowplow/Animation.dart';
import 'package:snowplow/companies/bottmnav.dart';

class DIrectDetails extends StatefulWidget {
  final Map<String, dynamic> requestdetails;
  final String? Username;
  const DIrectDetails(
      {super.key, required this.requestdetails, required this.Username});

  @override
  State<DIrectDetails> createState() => _DIrectDetailsState();
}

class _DIrectDetailsState extends State<DIrectDetails> {
  Map<String, dynamic>? request;
  String? customername;
  String? agencyid;
  bool isLoading = false;

  bool isAlreadysend = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    customername = widget.Username;
    request = widget.requestdetails;
    final status = request?['isAccepted'] as bool;
    if (status) {
      isAlreadysend = true; // Set this based on status
    }
  }

  Future<void> _initialize() async {
    await _getagencyid();
    // Now it waits until agencyid is ready
  }

  Future<void> _getagencyid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    agencyid = prefs.getString("agencyid");
    print("geted id from $agencyid");
  }

  Future<void> _reply() async {
    print("reply called");

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("https://snowplow.celiums.com/api/agencies/requestaccept"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "request_id": request!["requestId"],
          "customer_id"
          "agencyid": agencyid ?? "",    
          "api_mode": "test"
        }),
      );
      final resposnsedata = jsonDecode(response.body);
      print("Response: $resposnsedata");
      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Request submitted successfully!"),
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
            content: Text("Failed to submit REQUEST: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    catch (e) {
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
            ? SnowLoader()
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
                        isAlreadysend
                            ? _buildconfirmation(
                                ColorScheme.fromSeed(seedColor: Colors.blue),
                                GoogleFonts.ralewayTextTheme())
                            : _buildrequstform(
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
                style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 20,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(customername!)

                // style: GoogleFonts.poppins(
                //     fontSize: 14, fontWeight: FontWeight.w500)
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.numbers_outlined,
                  size: 20,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text((request!["customerId"] ?? "Unknown").toString()),

                // style: GoogleFonts.poppins(
                //     fontSize: 14, fontWeight: FontWeight.w500)
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
            _buildDetailItem(Icons.numbers, "Request id",
                request!["requestId"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.location_on, "Location",
                request!["area"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.access_time, "Uploaded",
                request!["created"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.calendar_today, "Preferred Date",
                request!["preferredDate"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.schedule, "Preferred Time",
                request!["preferredTime"]?.toString() ?? "N/A"),
            _buildDetailItem(Icons.place, "Service Area",
                request!["street"]?.toString() ?? "N/A"),
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

  Widget _buildrequstform(ColorScheme colorScheme, TextTheme textTheme) {
    final status = widget.requestdetails['status'];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Decline"),
                  ),
                ),
                isAlreadysend
                    ? Text(
                        'Already Accepted',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _reply,
                        child: const Text("Accept Request"),
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildconfirmation(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text("Request already sent",
                    style: textTheme.titleSmall?.copyWith(
                        color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
         
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
                  onPressed: isAlreadysend == true
                      ? null
                      : _reply, // Disable when loading
                  child:
                      isLoading ? SnowLoader() : const Text("Submit Request"),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
