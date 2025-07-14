// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snowplow/Animation.dart';
// import 'dart:convert';
// import 'package:snowplow/user/Authentication/signup.dart';
// import 'package:snowplow/user/bottomnav.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   final bool _isLoading = false;

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('email & password are required')));
//       return;
//     }
//     try {
//       var url = Uri.parse('https://snowplow.celiums.com/api/customers/login');
//       var responce = await http.post(
//         url,
//         headers: {
//           'content-type': 'application/json',
//         },
//         body: jsonEncode({
//           'email': email,
//           'password': password,
//           'api_mode': "test",
//         }),
//       );
//       final responcedata = jsonDecode(responce.body);

//       if (responce.statusCode == 200 && responcedata['status'] == 1) {
//         print(responcedata);
//         if (responcedata["message"] == "Customer Logged In") {
//           final Userid = responcedata['data']['customer_id'].toString();
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString("userId", Userid);

//           print('Login successful: $responcedata');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login successful'),backgroundColor: Colors.teal[200],),
//           );
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => Bottomnavbar()),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Invalid credentials')),
//           );
//         }
//       } else {
//         print('Login failed: ${responce.body}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Invalid email or password'),
//             backgroundColor: const Color.fromARGB(255, 226, 76, 17),
//           ),
//         );
//       }
//     } catch (e) {
//       print("Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something went wrong, please try again')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 213, 240, 245),
//       ),
//       backgroundColor: const Color.fromARGB(255, 213, 240, 245),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Text(
//                 'Snow Plow',
//                 style: GoogleFonts.raleway(
//                     color: const Color.fromARGB(255, 115, 200, 240),
//                     fontSize: 60,
//                     fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 'Snow removal App',
//                 style: GoogleFonts.lato(
//                     color: const Color.fromARGB(255, 52, 130, 213),
//                     fontSize: 20,
//                     fontWeight: FontWeight.w400),
//               ),
//               Container(
//                 padding: EdgeInsets.all(24),
//                 width: MediaQuery.of(context).size.width * 0.85,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(25),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.white.withOpacity(0.7),
//                       blurRadius: 1,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(height: 15),

//                       // Email Field
//                       TextFormField(
//                         controller: _emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           labelText: "Email",
//                           fillColor: Colors.white.withOpacity(0.7),
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15)),
//                           prefixIcon: Icon(
//                             Icons.email,
//                             color: Colors.blueAccent,
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Email is required";
//                           }
//                           if (value.isNotEmpty) {
//                             final trimmedValue = value.trim(); // Trim spaces
//                             final emailRegex =
//                                 RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
//                             if (!emailRegex.hasMatch(trimmedValue)) {
//                               return "Enter a valid Gmail address (e.g., example@gmail.com)";
//                             }
//                           }
//                           return null;
//                         },
//                       ),

//                       SizedBox(height: 15),

//                       // Password Field
//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText: _obscurePassword,
//                         decoration: InputDecoration(
//                           labelText: "Password",
//                           fillColor: Colors.white.withOpacity(0.7),
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15)),
//                           prefixIcon: Icon(
//                             Icons.lock,
//                             color: Colors.blueAccent,
//                           ),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _obscurePassword
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _obscurePassword = !_obscurePassword;
//                               });
//                             },
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Password is required";
//                           }
//                           if (value.length < 8) {
//                             return 'enter the 8 characters';
//                           }
//                           return null;
//                         },
//                       ),

//                       SizedBox(height: 20),

//                       // Login Button
//                       _isLoading
//                           ? SnowLoader()
//                           : ElevatedButton(
//                               onPressed: _login,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blueAccent,
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 60, vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20)),
//                                 shadowColor: Colors.black.withOpacity(0.3),
//                                 elevation: 8,
//                               ),
//                               child: Text("Log In"),
//                             ),

//                       SizedBox(height: 10),

//                       // Signup Option
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SignupScreen()),
//                           );
//                         },
//                         child: RichText(
//                           text: TextSpan(
//                             text: "Don't have an account? ",
//                             style: TextStyle(color: Colors.black, fontSize: 14),
//                             children: [
//                               TextSpan(
//                                 text: "Create one",
//                                 style: TextStyle(
//                                     color: Colors.blueAccent,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowplow/animation.dart';
import 'package:snowplow/user/Authentication/signup.dart';
import 'package:http/http.dart' as http;
import 'package:snowplow/user/bottomnav.dart';
// import 'package:snowplow/loader/snowloader.dart'; // if you have SnowLoader

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('email & password are required')));
      return;
    }
    try {
      var url = Uri.parse('https://snowplow.celiums.com/api/customers/login');
      var responce = await http.post(
        url,
        headers: {
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'api_mode': "test",
        }),
      );
      final responcedata = jsonDecode(responce.body);

      if (responce.statusCode == 200 && responcedata['status'] == 1) {
        print(responcedata);
        if (responcedata["message"] == "Customer Logged In") {
          final Userid = responcedata['data']['customer_id'].toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("userId", Userid);

          print('Login successful: $responcedata');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful'),
              backgroundColor: Colors.teal[200],
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Bottomnavbar()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid credentials')),
          );
        }
      } else {
        print('Login failed: ${responce.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: const Color.fromARGB(255, 226, 76, 17),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong, please try again')),
      );
    }
  }

  final Color _primaryColor = const Color(0xFF4FC3F7); // Ice blue
  final Color _secondaryColor = const Color(0xFFB3E5FC); // Light ice blue
  final Color _accentColor = const Color(0xFF01579B); // Deep blue
  final Color _backgroundColor =
      const Color.fromARGB(255, 213, 240, 245); // Very light blue
  final Color _textColor = const Color(0xFF263238); // Dark blue-gray

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Modern header with gradient and snow icon
            Container(
              color: _backgroundColor,
              height: 450,
              width: double.infinity,
              child: Image.asset(
                "assets/logindepageui.jpg",
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 40),

            // Modern login card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: _textColor),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: _accentColor),
                          prefixIcon: Icon(Icons.email, color: _primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _secondaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: _primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: _secondaryColor.withOpacity(0.1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          final emailRegex =
                              RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return "Enter a valid Gmail address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: _textColor),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: _accentColor),
                          prefixIcon: Icon(Icons.lock, color: _primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: _primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _secondaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: _primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: _secondaryColor.withOpacity(0.1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 8) {
                            return "Enter at least 8 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      _isLoading
                          ? SnowLoader()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                  shadowColor: _primaryColor.withOpacity(0.4),
                                ),
                                child: Text(
                                  "LOGIN",
                                  style: GoogleFonts.raleway(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),

                      // Signup Option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: TextStyle(
                                  color: _textColor.withOpacity(0.7))),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SignupScreen()),
                              );
                            },
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                color: _accentColor,
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
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
