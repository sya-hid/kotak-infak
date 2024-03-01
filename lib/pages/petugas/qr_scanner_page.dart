import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/pages/petugas/infak_form.dart';
import 'package:kotak_infak/provider/donatur_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      controller?.resumeCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    DonaturProvider donaturProvider = Provider.of<DonaturProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          QRView(
            cameraFacing: CameraFacing.back,
            key: qrKey,
            onQRViewCreated: (p0) async {
              p0.scannedDataStream.listen((event) async {
                setState(() {
                  isLoading = true;
                });
                Response response =
                    await donaturProvider.donaturById(event.code!);
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
                if (response.data != null) {
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfakForm(
                          donaturModel: response.data,
                        ),
                      ),
                    );
                  }
                } else {
                  // String notification = 'Data Tidak Ditemukan!';
                  var snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(response.message.toString()),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              });
            },
            overlay: QrScannerOverlayShape(
                borderRadius: 20,
                borderWidth: 10,
                borderColor: Theme.of(context).colorScheme.primary),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
