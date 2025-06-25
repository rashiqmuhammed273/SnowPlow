// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snowplow/companies/loginpage.dart';
// import 'package:http/http.dart' as http;
// import 'package:snowplow/user/signup.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController fullNameController = TextEditingController();

//   final TextEditingController emailController = TextEditingController();

//   final TextEditingController locationcontroller = TextEditingController();

//   final TextEditingController phoneController = TextEditingController();

//   final TextEditingController passwordController = TextEditingController();

//   final TextEditingController confirmPasswordController =
//       TextEditingController();

// void addinfo() async {
//   String companyId = uuid.v4();
//   String fullname = fullNameController.text.trim();
//   String email = emailController.text.trim();
//   String location = locationcontroller.text.trim();
//   String phone = phoneController.text.trim();
//   String password = passwordController.text.trim();
//   String confirmPassword = confirmPasswordController.text.trim();

//   if (fullname.isEmpty || location.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text("All fields are required"),
//       backgroundColor: Colors.red,
//     ));
//     return;
//   }

//   if (password != confirmPassword) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('The password is not matching'),
//       backgroundColor: Colors.red,
//     ));
//     return;
//   }

//   try {
//     String firebaseUrl = "https://firestore.googleapis.com/v1/projects/snowplow-3163e/databases/(default)/documents/company/$companyId";

//     final response = await http.post(
//       Uri.parse(firebaseUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "fields": {
//           'id': {"stringValue": companyId},
//           "fullname": {"stringValue": fullname},
//           "email": {"stringValue": email},
//           "phone": {"stringValue": phone},
//           "location": {"stringValue": location},
//           "password": {"stringValue": password}, 
//           "createdAt": {"timestampValue": DateTime.now().toUtc().toIso8601String()}
//         }
//       }),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {


      
//       // ✅ Save companyId in SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('company_id', companyId);

    

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Registration successful'),
//         backgroundColor: Colors.green,
//       ));

//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => logScreen()));
//     } else {
//       throw Exception("Failed to add company: ${response.body}");
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Error: ${e.toString()}'),
//       backgroundColor: Colors.red,
//     ));
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: const Color.fromARGB(255, 213, 240, 245),
//       body: SingleChildScrollView(
//         // Prevents overflow when keyboard is opened
//         child: Padding(
//           padding:
//               const EdgeInsets.symmetric(vertical: 50), // Adds space from top
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 40,
//               ),
//               Text(
//                 'Snow Plow',
//                 style: GoogleFonts.raleway(
//                     color: const Color(0xFF73C8F0),
//                     fontSize: 60,
//                     fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 'Snow removal App',
//                 style: GoogleFonts.lato(
//                     color: const Color(0xFF3482D5),
//                     fontSize: 20,
//                     fontWeight: FontWeight.w400),
//               ),
//               SizedBox(height: 20), // Added spacing
//               Center(
//                 child: Container(
//                   padding: EdgeInsets.all(24),
//                   width: MediaQuery.of(context).size.width * 0.85,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.4),
//                     borderRadius: BorderRadius.circular(25),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.white.withOpacity(0.3),
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                       ),
//                     ],
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         SizedBox(height: 10),
//                         Text(
//                           "Register Here",
//                           style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blueAccent),
//                         ),
//                         SizedBox(height: 20),
//                         buildTextField(
//                             Icons.person, "company Name", fullNameController),
//                         buildTextField(
//                             Icons.email, "Email Address", emailController,
//                             isEmail: true),
//                         buildTextField(Icons.location_on_outlined, "Location",
//                             locationcontroller,
//                             isLocation: true),
//                         buildTextField(
//                             Icons.phone, "Phone Number", phoneController,
//                             isnumber: true),
//                         buildTextField(
//                             Icons.lock, "Password", passwordController,
//                             isPassword: true, obscureText: true),
//                         buildTextField(Icons.lock, "Confirm Password",
//                             confirmPasswordController,
//                             obscureText: true, isPassword: true),
//                         SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () {
//                             if (_formKey.currentState!.validate()) {
//                               addinfo();
//                             }
//                           },
//                           // Handle sign-up logic

//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blueAccent,
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 60, vertical: 16),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20)),
//                             shadowColor: Colors.black.withOpacity(0.3),
//                             elevation: 8,
//                           ),
//                           child: Text("Sign Up",
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold)),
//                         ),
//                         SizedBox(height: 10),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pop(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => logScreen()));
//                           },
//                           child: RichText(
//                             text: TextSpan(
//                               text: "Already have an account? ",
//                               style:
//                                   TextStyle(color: Colors.black, fontSize: 14),
//                               children: [
//                                 TextSpan(
//                                   text: "Log in",
//                                   style: TextStyle(
//                                       color: Colors.blueAccent,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(
//       IconData icon, String hintText, TextEditingController controller,
//       {bool obscureText = false,
//       bool isLocation = false,
//       bool isEmail = false,
//       bool isPassword = false,
//       bool isnumber = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: isnumber ? TextInputType.number : TextInputType.text,
//         inputFormatters:
//             isnumber ? [FilteringTextInputFormatter.digitsOnly] : [],
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.blueAccent),
//           hintText: hintText,
//           filled: true,
//           fillColor: Colors.white.withOpacity(0.7),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return "$hintText is required";
//           }
//           if (isEmail) {
//             final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
//             if (!emailRegex.hasMatch(value)) {
//               return "Enter a valid Gmail address (e.g., example@gmail.com)";
//             }
//           }
//           if (isPassword && value.length < 8) {
//             return "Password must be at least 8 characters";
//           }
//           if (isnumber && value.length < 10) {
//             return "number must be atleast 10 characters";
//           }
//           if (isnumber && value.length > 10) {
//             return "number can't be more than 10 characters";
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/companies/authentication/loginpage.dart';
import 'package:snowplow/user/Authentication/loginpage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

class Cmpsignup extends StatefulWidget {
  @override
  State<Cmpsignup> createState() => _CmpsignupState();
}

class _CmpsignupState extends State<Cmpsignup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _countrycontroller = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  
  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {});

      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String phone = _phoneController.text.trim();
      String password = _passwordController.text.trim();
      String country = _countrycontroller.text.trim();

      try {
        String url = "https://snowplow.celiums.com/api/agencies/register";

        Map<String, dynamic> userData = {
          'name': name,
          'email': email,
          'phone': phone,
          'country': country,
          'password': password,
          "api_mode": "test"
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-type": "application/json",
          },
          body: jsonEncode(userData),
        );
        print("response:${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          print(response.statusCode);
          print(response.body);
          var responseData = jsonDecode(response.body);
          final userid = responseData['data']['agency_id'].toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          print("responseData :$responseData");
          // Store the API key for future requests
          await prefs.setString("_apikey", "7161092a3ab46fb924d464e65c84e35");

          // Store the email as userId if needed
          await prefs.setString("agencyId", userid);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Registration Successful"),
                backgroundColor: Colors.teal[200]),
          );
          // Navigator.pushReplacementNamed(context, "/login");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Cmplogin()));

          _formKey.currentState!.reset();
        } else {
          final errorMsg =
              jsonDecode(response.body)['message'] ?? "Registration failed";
          throw Exception(errorMsg);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }

      setState(() {});
    }
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    backgroundColor: const Color.fromARGB(255, 213, 240, 245),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Section
              Column(
                children: [
                  Text(
                    'Snow Plow',
                    style: GoogleFonts.raleway(
                      color: const Color(0xFF73C8F0),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Snow removal App',
                    style: GoogleFonts.lato(
                      color: const Color(0xFF3482D5),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Form Container
              Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form Title
                      Text(
                        "Register Here",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Form Fields
                      buildTextField(
                        Icons.person_outline, 
                        "Full Name", 
                        _nameController,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      buildTextField(
                        Icons.email_outlined, 
                        "Email Address", 
                        _emailController,
                        isEmail: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      buildTextField(
                        Icons.phone_android_outlined, 
                        "Phone Number", 
                        _phoneController,
                        isnumber: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      buildTextField(
                        Icons.location_on_outlined, 
                        "Country", 
                        _countrycontroller,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      buildTextField(
                        Icons.lock_outline, 
                        "Password", 
                        _passwordController,
                        isPassword: true, 
                        obscureText: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      buildTextField(
                        Icons.lock_outline, 
                        "Confirm Password", 
                        _confirmPasswordController,
                        obscureText: true, 
                        isPassword: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sign Up Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Log in",
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildTextField(
  IconData icon, 
  String hintText, 
  TextEditingController controller, {
  bool obscureText = false,
  bool isEmail = false,
  bool isPassword = false,
  bool isnumber = false,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: isnumber ? TextInputType.phone : TextInputType.text,
    inputFormatters: isnumber ? [FilteringTextInputFormatter.digitsOnly] : [],
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blue[600]),
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "$hintText is required";
      }
      if (isEmail) {
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
        if (!emailRegex.hasMatch(value)) {
          return "Enter a valid Gmail address (e.g., example@gmail.com)";
        }
      }
      if (isPassword && value.length < 8) {
        return "Password must be at least 8 characters";
      }
      if (isnumber && value.length != 10) {
        return "Phone number must be 10 digits";
      }
      return null;
    },
  );
}
}