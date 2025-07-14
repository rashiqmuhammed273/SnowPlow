import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/user/homepage.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  // String? userId;
  // String? token;
  String selectedOption = "";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedAreaType = "";
  String? selectedservicetype;
  String selectedCompany = "";
  TextEditingController areaController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String? formattedDate;
  String? formattedtime;
  String? _urgency = "";
  bool optselected = true;
  bool isLoading = true;
  double? serviceLatitude;
  double? serviceLongitude;

  String? base64Image;
  String? imageExtension;

  final picker = ImagePicker();
  File? _selectedImage;

  List<String> servicetype = [];

  List<String> companyList = [];

  @override
  void initState() {
    super.initState();
    _fetchServicetype();
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

  // Future<void> _fetchcompanies() async {
  //   String api_url = "http://snowplow.celiums.com/api/agencies/list";
  //   try {
  //     final response = await http.get(Uri.parse(api_url));
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> data = jsonDecode(response.body);
  //       List<String> fetchedCompanies = [];

  //       if (data.containsKey("data")) {
  //         for (var doc in data["data"]) {
  //           String companyName = doc["agency_name"];
  //           fetchedCompanies.add(companyName);
  //         }
  //       }
  //       setState(() {
  //         companyList = fetchedCompanies;
  //       });
  //     } else {
  //       print("Failed to fetch companies: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error fetching companies: $e");
  //   }
  // }

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

        final now = DateTime.now(); // today’s real date
        final dt = DateTime(
          // year, month, day, hour, min
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // 24‑hour with seconds -> “14:30:00”
        formattedtime = DateFormat('hh:mm:ss').format(dt);
        

        // If you prefer “02:30 PM”:
        // formattedtime = DateFormat('hh:mm a').format(dt);
      });
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

  //to add image///
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

  //////////pickimage function///////////

//////.......bid request.........///////////
  void _submitbidRequest() async {
    if (areaController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        locationController.text.isEmpty ||
        selectedservicetype == null ||
        _urgency!.isEmpty ||
        selectedOption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: const Color.fromARGB(255, 121, 170, 210),
        ),
      );
      return;
    }

    //    String? base64Image;
    // String? imageExtension;
    // if (_selectedImage != null) {
    //   List<int> imageBytes = await _selectedImage!.readAsBytes();
    //   base64Image = base64Encode(imageBytes);
    //   imageExtension = _selectedImage!.path.split('.').last;
    // }

    String requestId = const Uuid().v4();

    ////getting userid
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString("token");

    /// Determine Firestore collection

    String bidurl = 'https://snowplow.celiums.com/api/bids/createrequest';

    Map<String, dynamic> requestData = {
      "customer_id": userId,
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

    try {
      final response = await http.post(
        Uri.parse(bidurl),
        headers: {
          "Content-Type": "application/json",
          "api_mode": "test",
          if (token != null) "Authorization": token,
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print("✅ Request posted successfully  with ID: $requestId");
        print("request data is $response");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request submitted successfully!"),
            backgroundColor: const Color.fromARGB(255, 121, 170, 210),
          ),
        );

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
    setState(() => isLoading = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 160, 200, 236),
        title: Text(
          "Snow Plow",
          style: GoogleFonts.raleway(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 186, 205, 222),
      body: Center(
        child: Container(
          width: 360,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Request Service',
                  style: GoogleFonts.raleway(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 15),
                buildLocationField(),
                buildservicetypeField(),
                buildInputField('Approximate Area:', areaController),
                // buildDropdownField(),
                buildDatePickerField(
                    'Preferred Date', () => _pickDate(context)),
                buildTimePickerField(
                    'Preferred Time', () => _pickTime(context)),
                SizedBox(height: 12),
                Text('choose urgency level',
                    style: GoogleFonts.raleway(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildUrgencybutton('Urgent'),
                    SizedBox(width: 20),
                    buildUrgencybutton('Flexible')
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                _selectedImage == null
                    ? Text(
                        'No images selected',
                        style: TextStyle(color: Colors.grey),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, height: 100),
                      ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 15),
                Text("Choose Request Type",
                    style: GoogleFonts.raleway(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildRadioButton('Bid'),
                    SizedBox(width: 20),
                  ],
                ),
                // if (selectedOption == "Direct") SizedBox(height: 10),
                selectedOption == "direct"
                    ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Submit', style: TextStyle(fontSize: 18)),
                      )
                    : ElevatedButton(
                        onPressed: _submitbidRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Submit', style: TextStyle(fontSize: 18)),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCompanyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Text("Select Company",
            style:
                GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedCompany.isEmpty ? null : selectedCompany,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: companyList.map((company) {
            return DropdownMenuItem(
              value: company,
              child: Text(company),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCompany = value!;
            });
          },
        ),
      ],
    );
  }

  Widget buildDatePickerField(String label, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Select Date'
                      : '${selectedDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(fontSize: 14),
                ),
                Icon(Icons.calendar_today, color: Colors.blueAccent),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget buildTimePickerField(String label, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime == null
                      ? 'Select Time'
                      : selectedTime!.format(context),
                  style: TextStyle(fontSize: 14),
                ),
                Icon(Icons.access_time, color: Colors.blueAccent),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  // Widget buildDropdownField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text("Select Area Type",
  //           style:
  //               GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w500)),
  //       SizedBox(height: 4),
  //       DropdownButtonFormField<String>(
  //         value: selectedAreaType.isEmpty ? null : selectedAreaType,
  //         decoration: InputDecoration(
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //         items: areaTypes.map((area) {
  //           return DropdownMenuItem(
  //             value: area,
  //             child: Text(area),
  //           );
  //         }).toList(),
  //         onChanged: (value) {
  //           setState(() {
  //             selectedAreaType = value!;
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget buildservicetypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select service Type",
            style:
                GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          hint: Text('Please select a service'),
          value: selectedservicetype,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: servicetype.map((service) {
            return DropdownMenuItem(
              value: service,
              child: Text(service),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedservicetype = value!;
            });
          },
        ),
      ],
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

///////radio button for direct/bid option////////
  Widget buildRadioButton(String title) {
    return Row(
      children: [
        Radio<String>(
          value: title,
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value!;
            });
          },
          activeColor: Colors.blueAccent,
        ),
        Text(title, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location",
            style:
                GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        TextField(
          controller: locationController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.my_location, color: Colors.blueAccent),
              onPressed: () {
                _getcurrentlocation();
              },
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
