import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui';

class MapExample extends StatefulWidget {
  final double latitude, longitude;
  const MapExample({Key? key, required this.latitude, required this.longitude});

  @override
  State<MapExample> createState() => _MapExampleState();
}

class _MapExampleState extends State<MapExample> {
  LatLng mylatlong = LatLng(26.850000, 80.949997);
  String address = 'Lucknow';

  setMarker(LatLng value) async {
    mylatlong = value;

    List<Placemark> result =
        await placemarkFromCoordinates(widget.latitude, widget.longitude);
    mylatlong = LatLng(widget.latitude, widget.longitude);
    if (result.isNotEmpty) {
      address =
          '${result[0].name}, ${result[0].locality} ${result[0].administrativeArea}';
    }

    setState(() {});
    Fluttertoast.showToast(msg: '📍' + address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: mylatlong, zoom: 12),
        markers: {
          Marker(
              infoWindow: InfoWindow(title: address),
              position: mylatlong,
              draggable: true,
              markerId: MarkerId('1'),
              onDragEnd: (value) {
                print(value);
                setMarker(value);
              }),
        },
        onTap: (value) {
          setMarker(value);
        },
      ),
    );
  }
}
