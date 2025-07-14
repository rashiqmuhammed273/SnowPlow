import 'package:flutter/material.dart';
import 'package:snowplow/companies/Bid%20data/Showbids.dart';
import 'package:snowplow/companies/Direct%20Data/Showdirect.dart';

class Tapbarscreen extends StatefulWidget {
  const Tapbarscreen({super.key, required this.agencydata});
  final String? agencydata;

  @override
  State<Tapbarscreen> createState() => _TapbarscreenState();
}

class _TapbarscreenState extends State<Tapbarscreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  icon: Icon(Icons.handshake,
                      color: Color.fromARGB(255, 160, 200, 236)),
                  text: "bid requests",
                ),
                Tab(
                  icon: Icon(
                    Icons.person_4_outlined,
                    color: Color.fromARGB(255, 160, 200, 236),
                  ),
                  text: "direct requests",
                ),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  Bidrequest(),
                  Directrequest(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
