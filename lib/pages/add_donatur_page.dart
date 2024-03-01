import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/pages/print_donatur_page.dart';
import 'package:kotak_infak/models/category_model.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/category_provider.dart';
import 'package:kotak_infak/provider/donatur_provider.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:kotak_infak/provider/user_provider.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:kotak_infak/widgets/custom_textform_field.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:kotak_infak/models/user_model.dart';

class AddDonaturPage extends StatefulWidget {
  const AddDonaturPage({super.key});

  @override
  State<AddDonaturPage> createState() => _AddDonaturPageState();
}

class _AddDonaturPageState extends State<AddDonaturPage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool cetakQrcode = false;

  final _geopointController = TextEditingController();
  final _alamatController = TextEditingController();
  final TextEditingController _olehController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? currentCategory;
  // String? _currentAddress;
  late MapController mapController = MapController();
  final _olehFocus = FocusNode();
  final _alamatFocus = FocusNode();
  final _positionFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _noHpFocus = FocusNode();
  final _nameFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  void dispose() {
    super.dispose();
    mapController;
  }

  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  bool isLoadingMap = false;
  bool isLoadingSave = false;
  LatLng? currentLocation = const LatLng(0, 0);
  // LatLng? currentLocation = const LatLng(0.621, 101.417);
  String? currentAddress = '';

  @override
  Widget build(BuildContext context) {
//
    CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context);
    categoryProvider.allData();
    List<Map<String, dynamic>> categories = categoryProvider.categories;
    categoryProvider.allData();
    //
    UsersProvider usersProvider = Provider.of<UsersProvider>(context);
    usersProvider.allUser();
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel? currentUser = authProvider.user;

    getAddress(LatLng latLng) async {
      List<Placemark> placemark =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      Placemark place = placemark[0];
      setState(() {
        currentAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea} ${place.postalCode}';
        _alamatController.text = currentAddress!;
      });
    }

    getCurrentLocation() async {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) async {
        await getAddress(LatLng(position.latitude, position.longitude));
        setState(() {
          _namaController.text = 'nam';
          currentLocation = LatLng(position.latitude, position.longitude);
          _geopointController.text =
              'Lat: ${position.latitude}, Lng: ${position.longitude}';
        });
      }).catchError((e) {
        // print(e);
      });
    }

    resetForm() {
      _namaController.clear();
      _olehController.clear();
      _noHpController.clear();
      _emailController.clear();
      _geopointController.clear();
      _alamatController.clear();
      currentCategory = null;
    }

    getPosition() async {
      showModalBottomSheet(
        showDragHandle: true,
        useSafeArea: true,
        isScrollControlled: true,
        elevation: 3,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        // constraints: const BoxConstraints.expand(),
        constraints: BoxConstraints.tightFor(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.9),

        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateBottomSheet) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      maxZoom: 18,
                      interactiveFlags:
                          InteractiveFlag.all & ~InteractiveFlag.rotate,
                      onTap: (tapPosition, newpoint) async {
                        await getAddress(newpoint);
                        _animatedMapMove(newpoint, mapController.zoom);
                        setStateBottomSheet(() {
                          currentLocation = newpoint;
                          _geopointController.text =
                              'Lat: ${newpoint.latitude}, Lng: ${newpoint.longitude}';
                        });
                      },
                      center: currentLocation!.latitude != 0
                          ? LatLng(currentLocation!.latitude,
                              currentLocation!.longitude)
                          : const LatLng(0.621, 101.417),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'dev.fleaflet.flutter_map.example',
                      ),
                      currentLocation != const LatLng(0, 0)
                          ? MarkerLayer(
                              markers: [
                                Marker(
                                    anchorPos: AnchorPos.align(AnchorAlign.top),
                                    point: currentLocation!,
                                    builder: (ctx) => const Icon(
                                          Icons.location_on,
                                          size: 28,
                                        ))
                              ],
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  isLoadingMap
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink(),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () async {
                              setStateBottomSheet(() {
                                isLoadingMap = true;
                              });
                              // await positionProvider.getCurrentPosition();
                              await getCurrentLocation();

                              _animatedMapMove(currentLocation!, 15);

                              setStateBottomSheet(() {
                                isLoadingMap = false;
                              });
                            },
                            icon: const Icon(Icons.gps_fixed_rounded)),
                        currentAddress != ''
                            ? Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(currentAddress!),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
      ).then((value) {});
    }

    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          _nameFocus.unfocus();
          _noHpFocus.unfocus();
          _emailFocus.unfocus();
          _positionFocus.unfocus();
          _alamatFocus.unfocus();
          _olehFocus.unfocus();
        },
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            shrinkWrap: true,
            padding: const EdgeInsets.all(10),
            children: [
              CustomTextFormField(
                focusNode: _nameFocus,
                controller: _namaController,
                label: 'Nama',
                hintText: 'Masukkan Nama Donatur',
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextFormField(
                focusNode: _noHpFocus,
                controller: _noHpController,
                hintText: 'Masukkan No HP',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                label: 'No. HP',
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextFormField(
                  focusNode: _emailFocus,
                  controller: _emailController,
                  hintText: 'Masukkan Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Email'),
              const SizedBox(
                height: 10,
              ),
              CustomTextFormField(
                focusNode: _positionFocus,
                readOnly: true,
                controller: _geopointController,
                hintText: 'Masukkan Koordinat Donatur',
                label: 'Koordinat',
                keyboardType: TextInputType.text,
                prefixIcon: Icons.location_on,
                onTap: () {
                  getPosition();
                },
                // onTap: _getCurrentPosition,
              ),
              const SizedBox(height: 10),
              currentAddress != ''
                  ? CustomTextFormField(
                      focusNode: _alamatFocus,
                      label: 'Alamat',
                      controller: _alamatController,
                      hintText: 'Masukkan Alamat Donatur',
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.location_city_rounded,
                      maxLines: 3)
                  : const SizedBox.shrink(),
              currentAddress != ''
                  ? const SizedBox(height: 10)
                  : const SizedBox.shrink(),
              categories.isNotEmpty
                  ? DropdownButtonFormField(
                      isExpanded: true,
                      value: currentCategory,
                      decoration: const InputDecoration(
                        hintText: 'Category',
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        isCollapsed: false,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: Icon(Icons.menu_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(categories.length, (index) {
                        final CategoryModel category =
                            categories[index]['data'];
                        return DropdownMenuItem(
                            value: category.category,
                            child: Text(category.category!));
                      }),
                      onChanged: (value) {
                        setState(() {
                          currentCategory = value!.toString();
                        });
                      },
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              CustomTextFormField(
                focusNode: _olehFocus,
                controller: _olehController,
                label: 'Diterima Oleh',
                keyboardType: TextInputType.name,
                hintText: 'Masukkan Nama Yang Menerima',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: cetakQrcode,
                    onChanged: (value) {
                      setState(() {
                        cetakQrcode = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text('Cetak Qr Code')
                ],
              ),
              const SizedBox(height: 20),
              isLoadingSave
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          final Timestamp createdAt = Timestamp.now();

                          var id = DateFormat('yyMMddHHmmss')
                              .format(createdAt.toDate());

                          DonaturModel donatur = DonaturModel(
                              id: id,
                              alamat: _alamatController.text,
                              category: currentCategory,
                              geopoint: GeoPoint(currentLocation!.latitude,
                                  currentLocation!.longitude),
                              name: _namaController.text,
                              noHp: _noHpController.text,
                              email: _emailController.text,
                              createdAt: createdAt);
                          TransaksiModel transaksi = TransaksiModel(
                              id: id,
                              donatur: donatur,
                              petugas: currentUser,
                              idDonatur: donatur.id,
                              idPetugas: currentUser.id,
                              nominal: 0,
                              oleh: _olehController.text,
                              createdAt: createdAt);
                          setState(() {
                            isLoadingSave = true;
                          });
                          Response response =
                              await DonaturProvider().createData(id, donatur);
                          if (response.status == StatusType.success) {
                            await TransactionProvider()
                                .createData(id, transaksi);
                            if (cetakQrcode) {
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PrintDonaturPage(
                                            transaksi: transaksi)));
                              }
                            } else {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                            // resetForm();
                          } else {
                            final SnackBar snackBar = SnackBar(
                              backgroundColor:
                                  response.status == StatusType.error
                                      ? Colors.red
                                      : Colors.green,
                              elevation: 2,
                              content: Text(response.message!),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }
                          setState(() {
                            isLoadingSave = false;
                          });
                        }
                      },
                      text: 'Simpan',
                      iconData: Icons.save,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
