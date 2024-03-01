import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kotak_infak/provider/osrm.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class ProviderMaps with ChangeNotifier {
  LatLng _initialposition = const LatLng(-12.122711, -77.027475);
  LatLng get initialPos => _initialposition;

  late LatLng _finalposition;
  LatLng get finalPos => _finalposition;

  late MapController _mapController = MapController();
  MapController get mapController => _mapController;

  final List<Polyline> _polylines = [];
  List<Polyline> get polyline => _polylines;

  List<Marker> get markers => _markers;
  final List<Marker> _markers = [
    Marker(
      point: const LatLng(0.53528, 101.41),
      builder: (context) => const Icon(
        Icons.location_on,
        color: Colors.red,
      ),
    ),
    Marker(
      point: const LatLng(0.526124, 101.437),
      builder: (context) => const Icon(
        Icons.location_on,
        color: Colors.blue,
      ),
    )
  ];
  //0.5117,101.4376
  //0.5250,101.4349

  String distance = "";
  late LatLng _currentPosition = _initialposition;
  LatLng get currentPos => _currentPosition;

  void onCreated(MapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  String calculatedistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    double res = 12742 * asin(sqrt(a));
    if (res.toString().substring(0, 1) == "0") {
      res = (12742 * asin(sqrt(a))) * 1000;
      return "${res.toStringAsFixed(2)} m";
    } else {
      res = res;
      return "${res.toStringAsFixed(2)} Km";
    }
  }

  void addMarker(LatLng location) {
    // if (markers.length < 2) {
    _markers.add(Marker(
      point: location,
      builder: (context) => const Icon(
        Icons.location_on,
        // color: Colors.red,
        size: 36,
      ),
    ));
    // }
    _mapController.move(LatLng(location.latitude, location.longitude), 15);
    notifyListeners();
  }

  void routermap() async {
    polyline.clear();
    for (int i = 0; i < markers.length; i++) {
      // if (i == 0) {
      if (i == markers.length - 2) {
        _initialposition = markers.elementAt(i).point;
      }
      // if (i == 1) {
      if (i == markers.length - 1) {
        _finalposition = markers.elementAt(i).point;
      }
    }
    List<LatLng>? polylines = await ApiOSRM().getpoints(
        _initialposition.longitude.toString(),
        _initialposition.latitude.toString(),
        _finalposition.longitude.toString(),
        _finalposition.latitude.toString());
    createpolyline(polylines!);
    distance = calculatedistance(
        _initialposition.latitude,
        _initialposition.longitude,
        _finalposition.latitude,
        _finalposition.longitude);

    notifyListeners();
  }

  void createpolyline(List<LatLng> polylines) {
    _polylines.add(Polyline(
        // polylineId: PolylineId(_initialposition.toString()),
        strokeWidth: 5,
        points: polylines,
        color: Colors.blue));
    notifyListeners();
  }

  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((value) {
      LatLng newLatLng = LatLng(value.latitude!, value.longitude!);
      _currentPosition = newLatLng;
    });
    location.onLocationChanged.listen((event) {
      LatLng newLatLng = LatLng(event.latitude!, event.longitude!);
      _currentPosition = newLatLng;
    });

    notifyListeners();
  }

  void cleanpoint(int index) {
    polyline.clear();
    distance = '';
    markers.remove(markers.elementAt(index));
  }
}
