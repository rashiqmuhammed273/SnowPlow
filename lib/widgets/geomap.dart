  import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerPage extends StatefulWidget {
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _selectedPosition;
  String? _address;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pick Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(10.8505, 76.2711), // Kerala center
              zoom: 12,
            ),
            onTap: (position) async {
              List<Placemark> placemarks =
                  await placemarkFromCoordinates(position.latitude, position.longitude);

              setState(() {
                _selectedPosition = position;
                _address =
                    "${placemarks.first.street}, ${placemarks.first.locality}";
              });
            },
            markers: _selectedPosition != null
                ? {
                    Marker(
                      markerId: MarkerId("selected"),
                      position: _selectedPosition!,
                    )
                  }
                : {},
          ),
          if (_address != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    "lat": _selectedPosition!.latitude,
                    "lng": _selectedPosition!.longitude,
                    "address": _address!,
                  });
                },
                child: Text("Select this location"),
              ),
            )
        ],
      ),
    );
  }
}
