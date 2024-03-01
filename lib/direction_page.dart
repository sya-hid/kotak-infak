import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/provider/osrm.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class DirectionPage extends StatefulWidget {
  final DonaturModel donatur;
  const DirectionPage({super.key, required this.donatur});

  @override
  State<DirectionPage> createState() => _DirectionPageState();
}

class _DirectionPageState extends State<DirectionPage>
    with TickerProviderStateMixin {
  late MapController _mapController = MapController();
  List<Polyline> polylineCoordinate = [];
  LocationData? currentLocation;

  getPolyPoint() async {
    List<LatLng>? polylines = [];

    Response response = await ApiOSRM().getRoute(
      currentLocation!.longitude.toString(),
      currentLocation!.latitude.toString(),
      widget.donatur.geopoint!.longitude.toString(),
      widget.donatur.geopoint!.latitude.toString(),
    );
    polylines = response.data;

    polylineCoordinate.clear();
    if (!mounted) return;

    setState(() {
      if (polylines!.isNotEmpty) {
        polylineCoordinate.add(
            Polyline(points: polylines, strokeWidth: 6, color: Colors.blue));
      }
    });
  }

  getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((value) {
      setState(() {
        currentLocation = value;
      });
    });
    location.onLocationChanged.listen((event) {
      if (mounted) {
        setState(() {
          currentLocation = event;
          getPolyPoint();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    // currentLocation != null ? getPolyPoint() : null;
    _mapController = MapController();
  }

  @override
  void dispose() {
    super.dispose();
    getCurrentLocation();
    _mapController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                bounds: LatLngBounds(
                    LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    LatLng(widget.donatur.geopoint!.latitude,
                        widget.donatur.geopoint!.longitude)),
                boundsOptions: const FitBoundsOptions(
                    padding: EdgeInsets.all(20),
                    // inside: true,
                    maxZoom: 14,
                    forceIntegerZoomLevel: false),
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                center:
                    //  currentLocation!.latitude != 0
                    //     ?
                    LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                // : const LatLng(0.621, 101.417),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                PolylineLayer(
                  polylines: polylineCoordinate,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      anchorPos: AnchorPos.align(AnchorAlign.top),
                      point: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        size: 36,
                        color: Colors.blue,
                      ),
                    ),
                    Marker(
                      point: LatLng(widget.donatur.geopoint!.latitude,
                          widget.donatur.geopoint!.longitude),
                      builder: (context) {
                        return const Icon(
                          Icons.location_on,
                          size: 36,
                          color: Colors.red,
                        );
                      },
                    ),
                    // Marker(
                    //   point: sourceLocation,
                    //   builder: (context) {
                    //     return const Icon(
                    //       Icons.location_on,
                    //       size: 36,
                    //       color: Colors.blue,
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
    );
  }
}
