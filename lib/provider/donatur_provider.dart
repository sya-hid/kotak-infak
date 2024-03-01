import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/models/transaksi_model.dart';

class DonaturProvider with ChangeNotifier {
  List<TransaksiModel> _donaturs = [];
  List<TransaksiModel> get donaturs => _donaturs;

  set donaturs(List<TransaksiModel> donaturs) {
    _donaturs = donaturs;
    notifyListeners();
  }

  final CollectionReference collectionDonatur =
      FirebaseFirestore.instance.collection('donatur');
  final CollectionReference collectionTransaksi =
      FirebaseFirestore.instance.collection('transaksi');

  Future<List<TransaksiModel>> allDonatur() async {
    List<TransaksiModel> data = await collectionTransaksi.get().then((value) =>
        value.docs.map((e) => TransaksiModel.fromSnapshot(e)).toList());
    data = data.where((element) => element.nominal == 0).toList();
    data = data.sorted((a, b) => b.createdAt!.compareTo(a.createdAt!));
    _donaturs = data;
    notifyListeners();
    return data;
  }

  createData(String docId, DonaturModel user) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String message = '';
    dynamic data;
    StatusType status;
    try {
      // add user auth
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: user.email!,
          password: DateFormat('yyyyMMdd').format(user.createdAt!.toDate()));
      if (userCredential.user != null) {
        //add donatur
        await collectionDonatur.doc(docId).set(user.toJson());
      }
      data = user;
      message = 'Tambah User Sukses';
      status = StatusType.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'email/password accounts are not enabled.';
      }
      data = null;
      status = StatusType.error;
    }

    allDonatur();
    return Response(data: data, status: status, message: message);
  }

  Future<Response> donaturById(String idDonatur) async {
    List<DonaturModel> data = await collectionDonatur.get().then((value) =>
        value.docs.map((e) => DonaturModel.fromSnapshot(e)).toList());
    int index = data.indexWhere((element) => element.id == idDonatur);
    if (index == -1) {
      return Response(
          data: null,
          message: 'Data $idDonatur Tidak Ditemukan',
          status: StatusType.error);
    } else {
      return Response(
          data: data[index],
          message: 'Data Ditemukan',
          status: StatusType.success);
    }
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
}
