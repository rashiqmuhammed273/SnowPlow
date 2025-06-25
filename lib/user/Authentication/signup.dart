import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/user/Authentication/loginpage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
        String url = "https://snowplow.celiums.com/api/customers/register";

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
          final userid = responseData['data']['customer_id'].toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          print("responseData :$responseData");
          // Store the API key for future requests
          await prefs.setString("apiKey", "7161092a3ab46fb924d464e65c84e35");

          // Store the email as userId if needed
          await prefs.setString("userId", userid);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Registration Successful"),
                backgroundColor: Colors.teal[200]),
          );
          // Navigator.pushReplacementNamed(context, "/login");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));

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
      body: SingleChildScrollView(
        // Prevents overflow when keyboard is opened
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 50), // Adds space from top
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                'Snow Plow',
                style: GoogleFonts.raleway(
                    color: const Color(0xFF73C8F0),
                    fontSize: 60,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Snow removal App',
                style: GoogleFonts.lato(
                    color: const Color(0xFF3482D5),
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 20), // Added spacing
              Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Register Here",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                        SizedBox(height: 20),
                        buildTextField(
                            Icons.person, "Full Name", _nameController),
                        buildTextField(
                            Icons.email, "Email Address", _emailController,
                            isEmail: true),
                        buildTextField(
                            Icons.phone, "Phone Number", _phoneController,
                            isnumber: true),
                        buildTextField(
                            Icons.map, "country", _countrycontroller),
                        buildTextField(
                            Icons.lock, "Password", _passwordController,
                            isPassword: true, obscureText: true),
                        buildTextField(Icons.lock, "Confirm Password",
                            _confirmPasswordController,
                            obscureText: true, isPassword: true),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _register();
                            }
                          },
                          // Handle sign-up logic
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            shadowColor: Colors.black.withOpacity(0.3),
                            elevation: 8,
                          ),
                          child: Text("Sign Up",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Log in",
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      IconData icon, String hintText, TextEditingController controller,
      {bool obscureText = false,
      bool isEmail = false,
      bool isPassword = false,
      bool isnumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isnumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isnumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
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
          if (isnumber && value.length < 10) {
            return "number must be atleast 10 characters";
          }
          if (isnumber && value.length > 10) {
            return "number can't be more than 10 characters";
          }
          return null;
        },
      ),
    );
  }
}
