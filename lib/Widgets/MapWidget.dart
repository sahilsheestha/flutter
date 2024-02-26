import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freelance_booking_app/Models/Medical.dart';
import 'package:freelance_booking_app/Models/Parlour.dart';
import 'package:freelance_booking_app/Models/Salon.dart';
import 'package:freelance_booking_app/Providers/assistantMethods.dart';
import 'package:freelance_booking_app/Providers/locationProvider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController newGoogleMapController;

  Position currentPosition;

  var geoLocator = Geolocator();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future locatePosition(BuildContext ctx) async {
    try {
      final locations = Provider.of<LocationProvider>(ctx, listen: false);
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position;

      LatLng latLngPosition = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition =
          new CameraPosition(target: latLngPosition, zoom: 14);
      newGoogleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      await AssistantMethods.searchCoordinateAddress(position)
          .then((value) => locations.addLocation(value));
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicalFirebaseServiceList = Provider.of<List<Medical>>(context);
    final parlourFirebaseServiceList = Provider.of<List<Parlour>>(context);
    final salonFirebaseServiceList = Provider.of<List<Salon>>(context);
    bool expanded = false;
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Stack(
          children: [
            Container(
                height: deviceHeight * 0.3,
                width: deviceWidth * 0.9,
                child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  myLocationButtonEnabled: false,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (GoogleMapController controller) async {
                    _controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;

                    await locatePosition(context);
                  },
                )),
            Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.blue,
                ),
                margin: EdgeInsets.only(
                    left: deviceWidth * 0.78, top: deviceWidth * 0.03),
                child: Center(
                  child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context,
                            '/expandedmap'); // use this variable to maximise map
                      },
                      icon: Icon(
                        Icons.expand,
                        color: Colors.white,
                      )),
                ))
          ],
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.27,
                  decoration: BoxDecoration(
                      color: Color(0xff80FFAA),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: [
                      Text(
                        "${medicalFirebaseServiceList.length ?? 0}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Clinics",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.27,
                  decoration: BoxDecoration(
                      color: Color(0xff87D3FF),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: [
                      Text(
                        "${parlourFirebaseServiceList.length ?? 0}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Parlours",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.27,
                  decoration: BoxDecoration(
                      color: Color(0xffB3C8FF),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: [
                      Text(
                        "${salonFirebaseServiceList.length ?? 0}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Salons",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
            ],
          ),
        )
      ],
    );
  }
}

// need to find solution for geolocation problems
