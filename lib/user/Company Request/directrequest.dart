import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/user/homepage.dart';

class Directrequestpage extends StatefulWidget {
  const Directrequestpage({
    super.key,
  });

  @override
  State<Directrequestpage> createState() => _DirectrequestpageState();
}

class _DirectrequestpageState extends State<Directrequestpage> {
  TextEditingController areaController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController companycontroller = TextEditingController();
  DateTime? selectedDate;
  double? serviceLatitude;
  double? serviceLongitude;
  String selectedservicetype = '';
  String? _urgency = "";
  TimeOfDay? selectedTime;
  String? formattedDate;
  String? formattedtime;
  List<String> companyList = [];
  Map<String, String> companyNameToId = {};
  String selectedCompany = "";
  String? base64Image;
  bool isloading = false;
  String? imageExtension;
  List<String> servicetype = [];
  String? agencyid;
  String? agencyname;

  final picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    
  if (agencyname != null) {
    companycontroller.text = agencyname!;
  }
    _fetchServicetype();
     fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    try {
      final response = await http.post(
        Uri.parse("https://snowplow.celiums.com/api/agencies/list"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"per_page": "100", "page": "0", "api_mode": "test"}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> companies = data['data'];

        setState(() {
          companyList = companies
              .map<String>((item) => item['agency_name']?.toString() ?? '')
              .toList();

          /////looping name and id///
          for (var item in companies) {
            final name = item['agency_name']?.toString() ?? '';
            final id = item['agency_id']?.toString() ?? '';
            companyNameToId[name] = id;
          }
        });
      }
    } catch (e) {
      print("Company list error: $e");
    }
  }

  Future<void> _fetchServicetype() async {
    try {
      final response = await http.post(
        Uri.parse("https://snowplow.celiums.com/api/services/list"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"per_page": "10", "page": "0", "api_mode": "test"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> serviceList = data['data'];

        setState(() {
          servicetype = serviceList
              .map((item) => item['service_type'] as String)
              .toList();
        });

        print(data);
      } else {
        print('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  ////////////code for location/////////
  Future<void> _getcurrentlocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Location services are disabled,please turn on location"),
        backgroundColor: const Color.fromARGB(255, 121, 170, 210),
      ));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Location permission denied."),
        backgroundColor: const Color.fromARGB(255, 121, 170, 210),
      ));
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      serviceLatitude = position.latitude;
      serviceLongitude = position.longitude;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        setState(() {
          locationController.text = address;
        });
      } else {
        setState(() {
          locationController.text = "Location not found";
        });
      }
    } catch (e) {
      setState(() {
        locationController.text = "Failed to get address";
      });
    }
  }

  ////to add image///
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(imageBytes);
      imageExtension = _selectedImage!.path.split('.').last;
    }
  }

  void _pickDate(BuildContext context) async {
    DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
         final now = DateTime.now();
        final dt =DateTime(
          // year, month, day, hour, min
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        formattedtime = DateFormat('hh:mm:ss').format(dt);
      });
    }
  }

  void _submitRequest() async {
    if (areaController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        _urgency == null ||
        locationController.text.isEmpty ||
        selectedCompany.isEmpty ||
        selectedservicetype.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: const Color.fromARGB(255, 121, 170, 210),
        ),
      );
      return;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      String apiurl =
          "https://snowplow.celiums.com/api/requests/companyrequest";

      Map<String, dynamic> requestData = {
        "customer_id": userId,
        "agency_id": agencyid,
        "service_type": selectedservicetype,
        "service_city": locationController.text,
        "service_area": areaController.text,
        "service_street": locationController.text,
        "preferred_date": formattedDate,
        "preferred_time": formattedtime,
        "image": base64Image,
        "image_ext": imageExtension,
        "service_latitude": serviceLatitude,
        "service_longitude": serviceLongitude,
        "urgency_level": _urgency,
        "api_mode": "test"
      };

      print('RequestData → ${jsonEncode(requestData)}');

      try {
        final response = await http.post(
          Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "api_mode": "test",
          },
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          // final jsonData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Request submitted successfully!"),
              backgroundColor: const Color.fromARGB(255, 121, 170, 210),
            ),
          );
          // print("requeessst send to the compais $jsonData");

          // setState(() {
          //   locationController.clear();
          //   _urgency="";
          //   selectedservicetype="";
          //   areaController.clear();
          //   selectedDate = null;
          //   selectedTime = null;
          //   selectedOption = "";

          //   _selectedImage = null;
          //   selectedCompany = "";
          // });
          Navigator.pop(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to submit request"),
              backgroundColor: const Color.fromARGB(255, 255, 22, 22),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred while submitting request"),
            backgroundColor: const Color.fromARGB(255, 229, 103, 0),
          ),
        );
      }
    }
    setState(() => isloading = true);
  }

  ///////////////////
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Snow Plow",
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Request Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Request Service',
                      style: GoogleFonts.raleway(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // SizedBox(height: 20),

                    // Company Field
                    // _buildLabel("Service Provider"),
                    // // _buildReadOnlyField(companycontroller, "Company Name"),
                    // SizedBox(height: 16),

                    // Location Field

                        _buildLabel("Select company"),
                    DropdownButtonFormField<String>(
                      value: selectedCompany.isEmpty ? null : selectedCompany,
                      decoration: InputDecoration(
                        border: _inputBorder(),
                        enabledBorder: _inputBorder(),
                        focusedBorder: _inputBorder(color: Colors.blue),
                      ),
                      items: companyList.map((companyname) {
                        return DropdownMenuItem(
                          value: companyname,
                          child: Text(companyname),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCompany = value!;
                          agencyid = companyNameToId[selectedCompany];
                        });
                      },
                      hint: Text("Select company"),
                    ),
                    SizedBox(height: 16),

                    _buildLabel("Location"),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        hintText: "Enter location",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.my_location, color: Colors.blue),
                          onPressed: _getcurrentlocation,
                        ),
                        border: _inputBorder(),
                        enabledBorder: _inputBorder(),
                        focusedBorder: _inputBorder(color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Area Field
                    _buildLabel("Approximate Area"),
                    TextField(
                      controller: areaController,
                      decoration: InputDecoration(
                        hintText: "Area in square meters",
                        border: _inputBorder(),
                        enabledBorder: _inputBorder(),
                        focusedBorder: _inputBorder(color: Colors.blue),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),

                    // Service Type Dropdown
                
                    // Service Type Dropdown
                    _buildLabel("Service Type"),
                    DropdownButtonFormField<String>(
                      value: selectedservicetype.isEmpty
                          ? null
                          : selectedservicetype,
                      decoration: InputDecoration(
                        border: _inputBorder(),
                        enabledBorder: _inputBorder(),
                        focusedBorder: _inputBorder(color: Colors.blue),
                      ),
                      items: servicetype.map((area) {
                        return DropdownMenuItem(
                          value: area,
                          child: Text(area),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedservicetype = value!;
                        });
                      },
                      hint: Text("Select service type"),
                    ),
                    SizedBox(height: 16),

                    // Date & Time Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Preferred Date"),
                              _buildDatePicker(),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Preferred Time"),
                              _buildTimePicker(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Image Upload Section
                    _buildLabel("Upload Reference Photo"),
                    SizedBox(height: 8),
                    _selectedImage == null
                        ? _buildImagePlaceholder()
                        : _buildImagePreview(),
                    SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.upload),
                      label: Text("Pick Image"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildUrgencybutton('Urgent'),
                SizedBox(width: 20),
                buildUrgencybutton('Flexible')
              ],
            ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'SUBMIT REQUEST',
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper Widgets
  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
      ),
    );
  }

  InputBorder _inputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color ?? Colors.grey[300]!,
        width: 1,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _pickDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? "Select Date"
                  : "${selectedDate!.toLocal()}".split(' ')[0],
              style: TextStyle(
                color: selectedDate == null ? Colors.grey[400] : Colors.black,
              ),
            ),
            Icon(Icons.calendar_today, size: 20, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () => _pickTime(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedTime == null
                  ? "Select Time"
                  : selectedTime!.format(context),
              style: TextStyle(
                color: selectedTime == null ? Colors.grey[400] : Colors.black,
              ),
            ),
            Icon(Icons.access_time, size: 20, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 40, color: Colors.grey[400]),
            Text("No image selected", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget buildUrgencybutton(String level) {
    return Row(
      children: [
        Radio(
            value: level,
            groupValue: _urgency,
            onChanged: (value) {
              setState(() {
                _urgency = value!;
              });
            },
            activeColor: Colors.blueAccent),
        Text(level, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(_selectedImage!, height: 120, fit: BoxFit.cover),
    );
  }
}
