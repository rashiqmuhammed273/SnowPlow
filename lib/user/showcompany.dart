import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:snowplow/user/companydetail.dart';

class Showcompany extends StatefulWidget {
  const Showcompany({super.key});

  @override
  State<Showcompany> createState() => _ShowcompanyState();
}

class _ShowcompanyState extends State<Showcompany> {
  // String? companyId;
  bool isLoading = true;
  List<dynamic> companyData = [];
  bool isSearching = false;
  List<dynamic> filteredCompanies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getcompany();
  }

  ////method for search company////
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
          return name.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  ///method
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
            "page": "0", // or make it dynamic if you want pagination
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
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 201, 218, 234),
              Color.fromARGB(255, 221, 233, 239),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 24, right: 24, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSearching ? 'Search Companies' : 'Companies registered',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 53, 97, 126),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isSearching ? Icons.close : Icons.search,
                      color: Color.fromARGB(255, 53, 97, 126),
                    ),
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                        _searchController.clear();
                        filteredCompanies = companyData;
                      });
                    },
                  )
                ],
              ),
            ),

            if (isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  onChanged: filterSearch,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search by name or email",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Company list
            Expanded(
              child: isLoading
                  ? _buildSnowLoadingShimmer()
                  : filteredCompanies.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching companies found.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: getcompany,
                          color: Color.fromARGB(255, 115, 200, 240),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            itemCount: filteredCompanies.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final company = filteredCompanies[index];

                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CompanyDetailScreen(
                                          selectedcompany: company, agencyid: '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.business_sharp,
                                              size: 24,
                                              color: Color.fromARGB(
                                                  255, 115, 200, 240),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                company['name'],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color.fromARGB(
                                                      255, 53, 97, 126),
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 16,
                                              color: Color.fromARGB(
                                                  255, 115, 200, 240),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                        255, 115, 200, 240)
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.location_on_rounded,
                                                size: 18,
                                                color: Color.fromARGB(
                                                    255, 115, 200, 240),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                company['address'],
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  
Widget _buildSnowLoadingShimmer() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (context, index) => Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 235, 237),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 71, 230, 255).withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    ),
  );
}}


