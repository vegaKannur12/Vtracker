import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location2/CONTROLLER/printClass.dart';
import 'package:location2/mapModel.dart';
import 'package:location2/mapPage.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentAddress = 'Address    : ';
  late Position currentposition;
  String? formattedTime;
  String? date;
  Timer? timer;
  TextEditingController dateInput = TextEditingController();
  String formattedDate = "";
  Future _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() async {
        DateTime now = DateTime.now();
        String datetoday = DateFormat('dd-MM-yyyy').format(DateTime.now());
        currentposition = position;
        print("Street :${place.street}");
        print("Locality :${place.locality}");
        print("PostalCode :${place.postalCode}");
        print("AdministrativeArea :${place.administrativeArea}");
        print("Country :${place.country}");
        print("HashCode :${place.hashCode}");
        print("ISOCountryCode :${place.isoCountryCode}");
        print("Name :${place.name}");
        print("SubAdministrativeArea :${place.subAdministrativeArea}");
        print("SubLocality :${place.subLocality}");
        print("SubThoroughfare :${place.subThoroughfare}");
        print("Thoroughfare :${place.thoroughfare}");

        currentAddress =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.administrativeArea}, ${place.country}";
        Provider.of<PrintController>(context, listen: false).location(
            currentAddress.toString(),
            "$now",
            datetoday,
            "${place.street}",
            "${place.locality}",
            "${place.postalCode}",
            "${place.administrativeArea}",
            "${place.country}",
            "${place.hashCode}",
            "${place.isoCountryCode}",
            "${place.name}",
            "${place.subAdministrativeArea}",
            "${place.subLocality}",
            "${position.latitude}",
            "${position.longitude}",
            "0",
            context);
      });
    } catch (e) {
      print(e);
    }
  }

  void googleMap() async {
    String googleUrl = "comgooglemaps://?center=11.8684223,75.3654577";
    // "https://www.google.com/maps/search/?api=1&query=11.8684223,75.3654577";

    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else
      throw ("Couldn't open google maps");
  }

  @override
  void initState() {
    // TODO: implement initState
    DateTime now = DateTime.now();
    String datetoday = DateFormat('dd-MM-yyyy').format(DateTime.now());
    dateInput.text = datetoday;
    date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    formattedTime = DateFormat('HH:mm:ss').format(now);
    print(("Date : $date"));
    print(("Time : $formattedTime"));
    print(("Date : $now"));
    print("dafsf---->$date,$formattedTime");
    currentposition = Position(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    super.initState();
    // timer =
    //     Timer.periodic(Duration(seconds: 5), (Timer t) => _determinePosition()
    //         //  timerFun()
    //         );
  }

  timerFun() {
    print("....................................................$formattedTime");
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Get Location',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.w500, color: Colors.blue),
        )),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8),
        child: Consumer<PrintController>(
          builder:
              (BuildContext context, PrintController value, Widget? child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
                ListTile(
                  title: Text(
                    currentAddress,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      currentposition != null
                          ? Text('Latitude    : ' +
                              currentposition.latitude.toString())
                          : Container(),
                      currentposition != null
                          ? Text('Longitude : ' +
                              currentposition.longitude.toString())
                          : Container(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent),
                    onPressed: () {
                      _determinePosition();
                    },
                    child: Text(
                      'LOCATE',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                // MapSample
                                MapExample(
                                    latitude: currentposition.latitude,
                                    longitude: currentposition.longitude)));
                    // googleMap();
                  },
                  child: Text("Open GoogleMap"),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  height: 47,
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextField(
                    style: GoogleFonts.ptSerif(color: Colors.black),
                    controller: dateInput,
                    //editing controller of this TextField
                    decoration: const InputDecoration(
                      border: InputBorder.none,

                      icon: Icon(Icons.calendar_today), //icon of text field
                      //label text of field
                    ),
                    readOnly: true,
                    //set it true, so that user will not able to edit text
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2100));

                      if (pickedDate != null) {
                        print(
                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                        formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        print(
                            formattedDate); //formatted date output using intl package =>  2021-03-16
                        setState(() {
                          dateInput.text = formattedDate;
                          Provider.of<PrintController>(context, listen: false)
                              .locationHistory(formattedDate, context);
                        });
                      } else {}
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                value.histryLoad
                    ? SpinKitCircle(
                        color: Colors.blue,
                      )
                    : value.locHistryList.isEmpty
                        ? Container(
                            child: Center(
                              child: Text("No Data"),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                                itemCount: value.locHistryList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Card(
                                        child: ListTile(
                                          title: Column(
                                            children: [
                                              Text(value.locHistryList[index]
                                                      ['location_info']
                                                  .toString()),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "${value.locHistryList[index]['date'].toString()}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                      "${value.locHistryList[index]['time'].toString()}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500))
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                }),
                          )
              ],
            );
          },
        ),
      )),
    );
  }
}
