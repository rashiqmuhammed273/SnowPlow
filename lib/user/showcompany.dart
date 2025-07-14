// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:snowplow/user/companydetail.dart';

// class Showcompany extends StatefulWidget {
//   const Showcompany({super.key});

//   @override
//   State<Showcompany> createState() => _ShowcompanyState();
// }

// class _ShowcompanyState extends State<Showcompany> {
//   bool isLoading = true;
//   List<dynamic> companyData = [];
//   bool isSearching = false;
//   List<dynamic> filteredCompanies = [];
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   double _scrollOffset = 0;

//   @override
//   void initState() {
//     super.initState();
//     getcompany();
//     _scrollController.addListener(() {
//       setState(() {
//         _scrollOffset = _scrollController.offset;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void filterSearch(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         filteredCompanies = companyData;
//       });
//     } else {
//       setState(() {
//         filteredCompanies = companyData.where((company) {
//           final name = (company['name'] ?? '').toLowerCase();
//           final email = (company['email'] ?? '').toLowerCase();
//           final address = (company['address'] ?? '').toLowerCase();
//           return name.contains(query.toLowerCase()) ||
//               email.contains(query.toLowerCase()) ||
//               address.contains(query.toLowerCase());
//         }).toList();
//       });
//     }
//   }

//   Future<void> getcompany() async {
//     try {
//       String apiurl = "http://snowplow.celiums.com/api/agencies/list";

//       final response = await http.post(Uri.parse(apiurl),
//           headers: {
//             "Content-Type": "application/json",
//             "Accept": "application/json",
//           },
//           body: jsonEncode({
//             "per_page": "20",
//             "page": "0",
//             "api_mode": "test",
//           }));

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         List<dynamic> agencyList = responseData['data'];
//         print(agencyList);

//         if (agencyList.isNotEmpty) {
//           List<dynamic> companyList = agencyList.map((agency) {
//             return {
//               'name': agency['agency_name'] ?? 'Unknown',
//               'email': agency['agency_email'] ?? 'No Email',
//               'address': agency['agency_address'] ?? 'No Address',
//               'contact': agency['agency_phone'] ?? 'No Contact',
//               'id': agency['agency_id'].toString(),
//             };
//           }).toList();

//           final reversedList = companyList.reversed.toList();
//           setState(() {
//             companyData = reversedList;
//             filteredCompanies = reversedList;
//             isLoading = false;
//           });
//           print('Fetched companies: $companyData');
//         }
//       } else {
//         throw Exception(
//             "Failed to load agencies. Status: ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("🔥 Error fetching agencies: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.white,
//               Colors.blue.shade50,
//             ],
//           ),
//         ),
//         child: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // App Bar with Search
//             // Replace your existing SliverAppBar with this:
//             SliverAppBar(
//               expandedHeight: 100.0,
//               floating: false,
//               pinned: true,
//               backgroundColor: Colors.white.withOpacity(0.7),
//               flexibleSpace: LayoutBuilder(
//                 builder: (context, constraints) {
//                   final opacity = (constraints.maxHeight - kToolbarHeight) /
//                       (100.0 - kToolbarHeight);
//                   return FlexibleSpaceBar(
//                     background: ClipRect(
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(
//                             sigmaX: 10 * opacity, sigmaY: 10 * opacity),
//                         child: Container(
//                           color: Colors.transparent,
//                         ),
//                       ),
//                     ),
//                     title: Opacity(
//                       opacity: 1 - opacity,
//                       child: Text(
//                         isSearching ? 'Search Companies' : 'Companies',
//                         style: GoogleFonts.poppins(
//                           color: Colors.blue.shade900,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Content
//             isLoading
//                 ? SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 100),
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           color: Colors.blue.shade800,
//                         ),
//                       ),
//                     ),
//                   )
//                 : filteredCompanies.isEmpty
//                     ? SliverToBoxAdapter(
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 100),
//                           child: Center(
//                             child: Column(
//                               children: [
//                                 Icon(
//                                   Icons.business_outlined,
//                                   size: 60,
//                                   color: Colors.blue.shade300,
//                                 ),
//                                 SizedBox(height: 16),
//                                 Text(
//                                   'No companies found',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 18,
//                                     color: Colors.blue.shade800,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Try adjusting your search',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     color: Colors.blue.shade600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     : SliverPadding(
//                         padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
//                         sliver: SliverList(
//                           delegate: SliverChildBuilderDelegate(
//                             (context, index) {
//                               final company = filteredCompanies[index];
//                               return _buildCompanyCard(company, context);
//                             },
//                             childCount: filteredCompanies.length,
//                           ),
//                         ),
//                       ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchController,
//         onChanged: filterSearch,
//         decoration: InputDecoration(
//           hintText: 'Search by name, email or location...',
//           hintStyle: GoogleFonts.poppins(
//             color: Colors.grey.shade500,
//             fontSize: 14,
//           ),
//           prefixIcon: Icon(
//             Icons.search,
//             color: Colors.blue.shade800,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//         ),
//       ),
//     );
//   }

// // In your Showcompany class, modify the _buildCompanyCard method:
//   Widget _buildCompanyCard(Map<String, dynamic> company, BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CompanyDetailScreen(
//                 selectedcompany: company,
//               ),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.blue.shade800,
//                           Colors.blue.shade600,
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.business,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           company['name'],
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.blue.shade900,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           company['email'],
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             color: Colors.grey.shade600,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.location_on_outlined,
//                     size: 20,
//                     color: Colors.blue.shade800,
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       company['address'],
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.phone_outlined,
//                     size: 20,
//                     color: Colors.blue.shade800,
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     company['contact'],
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.blue.shade800,
//                         Colors.blue.shade600,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.shade200,
//                         blurRadius: 6,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(12),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => CompanyDetailScreen(
//                               selectedcompany: company,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'View Details',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             Icon(
//                               Icons.arrow_forward_rounded,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                           ],
//                         ),
//                       ),
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
// }

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:snowplow/user/companydetail.dart';

class Showcompany extends StatefulWidget {
  const Showcompany({super.key});

  @override
  State<Showcompany> createState() => _ShowcompanyState();
}

class _ShowcompanyState extends State<Showcompany> {
  bool isLoading = true;
  List<dynamic> companyData = [];
  bool isSearching = false;
  List<dynamic> filteredCompanies = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    getcompany();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCompanies = companyData;
      });
    } else {
      setState(() {
        filteredCompanies = companyData.where((company) {
          final name = (company['name'] ?? '').toLowerCase();
          final email = (company['email'] ?? '').toLowerCase();
          final address = (company['address'] ?? '').toLowerCase();
          return name.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase()) ||
              address.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Future<void> getcompany() async {
    try {
      String apiurl = "http://snowplow.celiums.com/api/agencies/list";

      final response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "per_page": "20",
            "page": "0",
            "api_mode": "test",
          }));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> agencyList = responseData['data'];
        print(agencyList);

        if (agencyList.isNotEmpty) {
          List<dynamic> companyList = agencyList.map((agency) {
            return {
              'name': agency['agency_name'] ?? 'Unknown',
              'email': agency['agency_email'] ?? 'No Email',
              'address': agency['agency_address'] ?? 'No Address',
              'contact': agency['agency_phone'] ?? 'No Contact',
              'id': agency['agency_id'].toString(),
            };
          }).toList();

          final reversedList = companyList.reversed.toList();
          setState(() {
            companyData = reversedList;
            filteredCompanies = reversedList;
            isLoading = false;
          });
          print('Fetched companies: $companyData');
        }
      } else {
        throw Exception(
            "Failed to load agencies. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("🔥 Error fetching agencies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar with Search
            SliverAppBar(
              expandedHeight:
                  140.0, // Increased from 100 to accommodate search field
              floating: false,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      children: [
                        SizedBox(
                            height:
                                kToolbarHeight + 12), // Added more top space
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSearchField(),
                        ),
                        SizedBox(height: 12), // Added bottom padding
                      ],
                    ),
                    title: _scrollOffset > 50 // Show title only when scrolled
                        ? Text(
                            isSearching ? 'Search Companies' : "",
                            style: GoogleFonts.poppins(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),

            // Content
            isLoading
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  )
                : filteredCompanies.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.business_outlined,
                                  size: 60,
                                  color: Colors.blue.shade300,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No companies found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final company = filteredCompanies[index];
                            return _buildCompanyCard(company, context);
                          },
                          childCount: filteredCompanies.length,
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: filterSearch,
        decoration: InputDecoration(
          hintText: 'Search company...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.blue.shade800,
            size: 22, // Slightly smaller icon
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    filterSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, // Reduced horizontal padding
            vertical: 14, // Reduced vertical padding
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompanyDetailScreen(
                  selectedcompany: company,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade800,
                            Colors.blue.shade600,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/companieslogo.png',
                        width: 120, // resize here
                        height: 120,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            company['email'],
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.blue.shade800,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        company['address'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: Colors.blue.shade800,
                    ),
                    SizedBox(width: 8),
                    Text(
                      company['contact'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade800,
                          Colors.blue.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyDetailScreen(
                                selectedcompany: company,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'View Details',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
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
}
