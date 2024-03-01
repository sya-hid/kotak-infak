import 'dart:developer';

import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/models/instansi_model.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/bluetooth_provider.dart';
import 'package:kotak_infak/provider/instansi_provider.dart';
import 'package:kotak_infak/provider/theme_provider.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;

class PrintDonaturPage extends StatefulWidget {
  // final DonaturModel donatur;
  final TransaksiModel transaksi;

  const PrintDonaturPage(
      {super.key,
      //  required this.donatur,
      required this.transaksi});

  @override
  State<PrintDonaturPage> createState() => _PrintDonaturPageState();
}

class _PrintDonaturPageState extends State<PrintDonaturPage> {
  Future<void> printTest1(
      TransaksiModel transaksi, InstansiModel instansi) async {
    bool conectionStatus = await PrintBluetoothThermal.connectionStatus;
    log("connection status: $conectionStatus");
    if (conectionStatus) {
      List<int> ticket = await buktiTransaksi(transaksi, instansi);
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      log("log test result:  $result");
    } else {
      //no conectado, reconecte
    }
  }

  bool isLoading = false;
  buktiTransaksi(TransaksiModel transaksi, InstansiModel instansi) async {
    DonaturModel donatur = transaksi.donatur!;
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();

    final generator = Generator(
        // optionlogtype == "58 mm" ?
        PaperSize.mm58
        // : PaperSize.mm80
        ,
        profile);
    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();
    final ByteData data =
        await rootBundle.load('assets/imageedit_1_6962058923.png');
    // final Uint8List bytesImg =
    //     data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // final Uint8List bytesImg = data.buffer.asUint8List();
    // img.Image? image = img.decodeImage(bytesImg);

    // bytes += generator.image(image!);

    bytes += generator.text(instansi.name!,
        styles: const PosStyles(
            bold: true,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            align: PosAlign.center),
        linesAfter: 0);
    bytes += generator.text(
        'Alamat: ${instansi.alamat},No.HP: ${instansi.noHp},email: ${instansi.email}',
        styles: const PosStyles(
            align: PosAlign.center,
            width: PosTextSize.size1,
            height: PosTextSize.size1),
        linesAfter: 1);
    bytes +=
        generator.qrcode(donatur.id!, size: QRSize.Size5, cor: QRCorrection.Q);
    bytes += generator.text('');
    bytes += generator.text(donatur.name!,
        styles: const PosStyles(
            align: PosAlign.center,
            width: PosTextSize.size1,
            height: PosTextSize.size1),
        linesAfter: 0);
    bytes += generator.text(
        'Alamat: ${donatur.alamat}, No. HP: ${donatur.noHp}, Email: ${donatur.email}',
        styles: const PosStyles(
            align: PosAlign.center,
            width: PosTextSize.size1,
            height: PosTextSize.size1),
        linesAfter: 1);
    bytes += generator.text(transaksi.petugas!.name!,
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(
        DateFormat('EEEE, dd-MMM-yyyy HH:mm:ss', 'id_ID')
            .format(donatur.createdAt!.toDate()),
        styles: const PosStyles(
            align: PosAlign.center,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            fontType: PosFontType.fontA));
    bytes += generator.beep(duration: PosBeepDuration.beep450ms, n: 5);
    // bytes += generator.hr(ch: '*');
    // bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    ThemeNotifier theme = Provider.of<ThemeNotifier>(context);
    BluetoothProvider bluetoothProvider =
        Provider.of<BluetoothProvider>(context);

    InstansiProvider instansiProvider = Provider.of<InstansiProvider>(context);
    InstansiModel instansiModel = instansiProvider.instansi;
    DonaturModel donatur = widget.transaksi.donatur!;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Preview',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          instansiModel.name!,
                          style: TextStyle(
                              fontSize:
                                  8 * MediaQuery.of(context).devicePixelRatio,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Alamat: ${instansiModel.alamat}, No. Hp: ${instansiModel.noHp}, email: ${instansiModel.email}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        bw.BarcodeWidget(
                            color: theme.getThemeMode() == ThemeMode.dark
                                ? Colors.white
                                : Colors.black,
                            data: donatur.id!,
                            barcode: bw.Barcode.qrCode()),
                        const SizedBox(height: 20),
                        Text(
                          '${donatur.name}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                            'Alamat: ${donatur.alamat}, No. HP: ${donatur.noHp}, Email: ${donatur.email}',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        Text(widget.transaksi.petugas!.name!),
                        Text(
                          DateFormat('EEEE, dd-MMM-yyyy HH:mm:ss', 'id_ID')
                              .format(donatur.createdAt!.toDate()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                bluetoothProvider.connected
                    ? isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await printTest1(widget.transaksi, instansiModel);
                              setState(() {
                                isLoading = false;
                              });
                            },
                            iconData: Icons.print,
                            text: 'Print')
                    : const Text('Tidak Terkoneksi Ke Printer'),
              ],
            ),
          ),
        ));
  }
}
