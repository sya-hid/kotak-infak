import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:latlong2/latlong.dart';

class DetailDonaturPage extends StatefulWidget {
  final TransaksiModel transaksi;
  const DetailDonaturPage({super.key, required this.transaksi});

  @override
  State<DetailDonaturPage> createState() => _DetailDonaturPageState();
}

class _DetailDonaturPageState extends State<DetailDonaturPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    DonaturModel donatur = widget.transaksi.donatur!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Donatur'),
      ),
      bottomSheet: BottomSheet(
        animationController: AnimationController(vsync: this),
        onClosing: () {},
        elevation: 2,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        constraints: BoxConstraints(
            maxWidth: double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.63),
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(flex: 1, child: Text('Nama')),
                  Expanded(
                      flex: 3,
                      child: Text(
                        donatur.name!,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                      ))
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kategori'),
                  Text(
                    donatur.category!,
                    textAlign: TextAlign.right,
                  )
                ],
              ),
              // const SizedBox(height: 5),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'No. Hp',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    donatur.noHp!,
                    textAlign: TextAlign.right,
                  )
                ],
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    donatur.email!,
                    textAlign: TextAlign.right,
                  )
                ],
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'Alamat',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        donatur.alamat!,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                      ))
                ],
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Diterima Oleh'),
                  Text(
                    widget.transaksi.oleh!,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Petugas'),
                  Text(
                    widget.transaksi.petugas!.name ?? "",
                    textAlign: TextAlign.right,
                  )
                ],
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tanggal"),
                  Text(
                    DateFormat('dd-MMMM-yyyy, HH:mm:ss', 'id_ID')
                        .format(widget.transaksi.createdAt!.toDate()),
                    textAlign: TextAlign.right,
                  )
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const NewRoutePage()));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             DirectionPage(donatur: donatur)));
                },
                text: 'Direction',
                iconData: Icons.directions,
              )
            ],
          );
        },
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.shortestSide,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
              maxZoom: 18,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              screenSize: Size(
                  double.infinity, MediaQuery.of(context).size.height * 0.2),
              zoom: 15,
              center: LatLng(
                  donatur.geopoint!.latitude, donatur.geopoint!.longitude)),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  anchorPos: AnchorPos.align(AnchorAlign.top),
                  point: LatLng(
                      donatur.geopoint!.latitude, donatur.geopoint!.longitude),
                  builder: (context) => const Icon(
                    Icons.location_on,
                    // color: Colors.red,
                    size: 28,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
