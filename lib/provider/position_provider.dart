import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
//
import 'package:geolocator/geolocator.dart';
//
import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart' as loc;

class PositionProvider extends ChangeNotifier {
  String? _currentAddress = '';
  String get currentAddress => _currentAddress!;
  LatLng _currentPosition = const LatLng(0, 0);
  LatLng get currentPosition => _currentPosition;

  set currentAddress(String address) {
    _currentAddress = address;
    notifyListeners();
  }

  set currentPosition(LatLng position) {
    _currentPosition = position;
    notifyListeners();
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);

      getAddress(_currentPosition);
    }).catchError((e) {
      debugPrint(e);
    });

    // loc.Location location = loc.Location();
    // await location.getLocation().then((value) {
    //   _currentPosition = LatLng(value.latitude!, value.longitude!);
    //   getAddress(_currentPosition);
    // }).catchError((e) {
    //   debugPrint(e);
    // });

    // location.onLocationChanged.listen((event) {
    //   _currentPosition = LatLng(event.latitude!, event.longitude!);
    //   print('onLocationChange');
    //   print(_currentPosition.latitude);
    //   getAddress(_currentPosition);
    // });
    notifyListeners();
  }

  Future<LatLng> getPosition() async {
    final hasPermission = await handleLocationPermission();

    if (hasPermission) {}

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      _currentPosition = LatLng(position.latitude, position.longitude);
      // await getAddress(_currentPosition);
    }).catchError((e) {
      print(e);
    });
    notifyListeners();
    return _currentPosition;
  }

  // Future<void> getAddressFromLatLng(LatLng position) async {
  //   await placemarkFromCoordinates(position.latitude, position.longitude)
  //       .then((List<Placemark> placemarks) {
  //     Placemark place = placemarks[0];
  //     _currentAddress =
  //         '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea} ${place.postalCode}';
  //   }).catchError((e) {
  //     debugPrint(e);
  //   });
  //   notifyListeners();
  // }

  Future<void> getAddress(LatLng latLng) async {
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude)
        .then((value) {
      Placemark place = value[0];
      _currentAddress =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea} ${place.postalCode}';
      _currentPosition = latLng;
      // _currentAddress = address;
    }).catchError((e) {
      debugPrint(e);
    });
    notifyListeners();
  }
}
