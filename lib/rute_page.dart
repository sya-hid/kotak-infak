import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kotak_infak/provider/route_provider.dart';
import 'package:kotak_infak/provider/osrm.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class RoutePage extends StatefulWidget {
  // final double lat, lng;
  const RoutePage({
    super.key,
    //  required this.lat, required this.lng
  });

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  String totalDistance = '';
  String totalDuration = '';
  // LatLng? point;
  LatLng point = const LatLng(0.621, 101.417);

  // String? _currentAddress;

  var location = [];
  late final MapController mapController;
  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final provmaps = Provider.of<ProviderMaps>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: provmaps.mapController,
            options: MapOptions(
              onMapReady: () => provmaps.onCreated(mapController),
              onTap: (tapPosition, point) {
                provmaps.addMarker(point);

                if (provmaps.markers.length > 1) {
                  provmaps.routermap();
                }
              },
              center: const LatLng(0.621, 101.417),
              zoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              // TileLayer(
              //   wmsOptions: WMSTileLayerOptions(
              //     baseUrl: 'https://{s}.s2maps-tiles.eu/wms/?',
              //     layers: ['s2cloudless-2021_3857'],
              //   ),
              //   subdomains: const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
              //   userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              // ),
              provmaps.polyline.isNotEmpty
                  ? PolylineLayer(
                      polylines: provmaps.polyline,
                    )
                  : const PolylineLayer(),
              MarkerLayer(
                markers: [
                  ...List.generate(
                      provmaps.markers.length > 2 ? 2 : provmaps.markers.length,
                      (index) {
                    LatLng newPoint = provmaps
                        .markers[provmaps.markers.length - (index + 1)].point;
                    return Marker(
                        point: newPoint,
                        builder: (context) {
                          return Icon(
                            Icons.location_on,
                            size: 30,
                            color: index == 0 ? Colors.red : Colors.blue,
                          );
                        });
                  }),
                  Marker(
                    point: LatLng(provmaps.currentPos.latitude,
                        provmaps.currentPos.longitude),
                    builder: (context) {
                      return const Icon(
                        Icons.location_on,
                        size: 30,
                        color: Colors.deepPurple,
                      );
                    },
                  )
                ],
              )
            ],
          ),
          provmaps.distance != ''
              ? Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    "Distance: ${provmaps.distance}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                )
              : const SizedBox.shrink(),
          Text(provmaps.currentPos.latitude.toString())
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provmaps.getCurrentLocation();
          provmaps.routermap();
        },
        // onPressed: provmaps.getCurrentLocation,
        child: const Icon(Icons.directions),
      ),
    );
  }
}

class NewRoutePage extends StatefulWidget {
  const NewRoutePage({super.key});

  @override
  State<NewRoutePage> createState() => _NewRoutePageState();
}

class _NewRoutePageState extends State<NewRoutePage> {
  static LatLng sourceLocation = const LatLng(0.563308, 101.452);
  // 0.565104, 101.450867
  static LatLng destination = const LatLng(0.564848, 101.46);

  // MapController mapController = MapController();
  List<Polyline> polylineCoordinate = [];
  List<Polyline> polylineCoordinate2 = [];
  LocationData? currentLocation;
  late final MapController _mapController;

  // final Completer<MapController> _controller = Completer();
  void getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((value) {
      // final newLatLng = LatLng(value.latitude!, value.longitude!);
      // _mapController.move(newLatLng, 16);
      currentLocation = value;
    });
    // MapController flutterMapController = await _controller.future;
    location.onLocationChanged.listen((event) {
      setState(() {
        currentLocation = event;
        getPolyPoint2();
      });
    });
  }

  void getPolyPoint() async {
    List<LatLng>? polylines = await ApiOSRM().getpoints(
      destination.longitude.toString(),
      destination.latitude.toString(),
      sourceLocation.longitude.toString(),
      sourceLocation.latitude.toString(),
    );
    setState(() {
      if (polylines!.isNotEmpty) {
        polylineCoordinate.add(
            Polyline(points: polylines, strokeWidth: 6, color: Colors.blue));
      }
    });
  }

  void getPolyPoint2() async {
    List<LatLng>? polylines = await ApiOSRM().getpoints(
      destination.longitude.toString(),
      destination.latitude.toString(),
      currentLocation!.longitude.toString(),
      currentLocation!.latitude.toString(),
    );
    polylineCoordinate2.clear();
    if (!mounted) return;
    setState(() {
      if (polylines!.isNotEmpty) {
        polylineCoordinate2.add(
            Polyline(points: polylines, strokeWidth: 6, color: Colors.red));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getPolyPoint();
    _mapController = MapController();
  }
// microsoft
// 37.4116103, -122.0713127
// googleplex building
// 37.4223878, -122.0841877

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                  // onMapReady: () => mapController,
                  center: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 15.5),
              children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: polylineCoordinate,
                  ),
                  PolylineLayer(
                    polylines: polylineCoordinate2,
                  ),
                  MarkerLayer(
                    anchorPos: AnchorPos.align(AnchorAlign.top),
                    markers: [
                      Marker(
                        point: destination,
                        builder: (context) {
                          return const Icon(
                            Icons.location_on,
                            size: 36,
                            color: Colors.red,
                          );
                        },
                      ),
                      Marker(
                        point: sourceLocation,
                        builder: (context) {
                          return const Icon(
                            Icons.location_on,
                            size: 36,
                            color: Colors.blue,
                          );
                        },
                      ),
                      Marker(
                        point: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!),
                        builder: (context) {
                          return const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 40,
                          );
                        },
                      )
                    ],
                  )
                ]),
    );
  }
}
