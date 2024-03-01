import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/position_provider.dart';
import 'package:latlong2/latlong.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransaksiModel> _transaksi = [];
  List<TransaksiModel> get transaksi => _transaksi;
// baru
  List<Map<String, dynamic>> _topDonaturs = [];
  List<Map<String, dynamic>> get topDonaturs => _topDonaturs;
  List<Map<String, dynamic>> _topUsers = [];
  List<Map<String, dynamic>> get topUsers => _topUsers;
  List<Map<String, dynamic>> _nearByDonaturs = [];
  List<Map<String, dynamic>> get nearByDonaturs => _nearByDonaturs;

  List<TransaksiModel> _historyDonaturByUser = [];
  List<TransaksiModel> get historyDonaturByUser => _historyDonaturByUser;
  List<TransaksiModel> _historyInfakByUser = [];
  List<TransaksiModel> get historyInfakByUser => _historyInfakByUser;
  List<TransaksiModel> _historyInfakByDonatur = [];
  List<TransaksiModel> get historyInfakByDonatur => _historyInfakByDonatur;

  // set infak(List<TransaksiModel> data) {
  //   _infak = data;
  //   notifyListeners();
  // }
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('transaksi');

  createData(String docId, TransaksiModel data) {
    collection.doc(docId).set(data.toJson());
    allData();
  }

  Future<List<TransaksiModel>> allData() async {
    List<TransaksiModel> data = await collection.get().then((value) =>
        value.docs.map((e) => TransaksiModel.fromSnapshot(e)).toList());
    _transaksi = data;
    notifyListeners();
    return data;
  }

  Future<List<TransaksiModel>> getHistoryDonaturByUser(String idPetugas) async {
    List<TransaksiModel> newTransaksi = _transaksi
        .where((element) =>
            element.nominal == 0 && element.petugas!.id == idPetugas)
        .sorted((a, b) => b.createdAt!.compareTo(a.createdAt!))
        .toList();
    _historyDonaturByUser = newTransaksi;
    // notifyListeners();
    return newTransaksi;
  }

  Future<List<TransaksiModel>> getHistoryInfakByDonatur(
      String idDonatur) async {
    List<TransaksiModel> newTransaksi = _transaksi
        .where((element) =>
            element.nominal != 0 && element.donatur!.id == idDonatur)
        .sorted((a, b) => b.createdAt!.compareTo(a.createdAt!))
        .toList();
    _historyInfakByDonatur = newTransaksi;
    // notifyListeners();
    return newTransaksi;
  }

  Future<List<TransaksiModel>> getHistoryInfakByUser(String idPetugas) async {
    // List<TransaksiModel> transaksi = await collection.get().then((value) =>
    //     value.docs.map((e) => TransaksiModel.fromSnapshot(e)).toList());
    List<TransaksiModel> newTransaksi = _transaksi
        .where(
            (element) => element.nominal != 0 && element.idPetugas == idPetugas)
        .sorted((a, b) => b.createdAt!.compareTo(a.createdAt!))
        .toList();
    _historyInfakByUser = newTransaksi;
    // notifyListeners();
    return _historyInfakByUser;
  }

  //Home
  Future<List<Map<String, dynamic>>> getNearByDonatur() async {
    // List<TransaksiModel> infak = await collection.get().then((value) =>
    //     value.docs.map((e) => TransaksiModel.fromSnapshot(e)).toList());
    List<TransaksiModel> newTransaksi =
        _transaksi.where((element) => element.nominal == 0).toList();
    List<Map<String, dynamic>> datas = [];
    LatLng currentPosition = await PositionProvider().getPosition();
    var distance = const Distance();
    for (var element in newTransaksi) {
      final meter = distance.as(
          LengthUnit.Meter,
          currentPosition,
          LatLng(element.donatur!.geopoint!.latitude,
              element.donatur!.geopoint!.longitude));
      datas.add({"data": element, "distance": meter});
    }
    datas = datas.sorted((a, b) => a['distance'].compareTo(b['distance']));

    _nearByDonaturs = datas.length > 5 ? datas.sublist(0, 5) : datas;
    // notifyListeners();
    return datas;
  }

  Future<List<Map<String, dynamic>>> getTopDonaturByTotalDonasi() async {
    // List<TransaksiModel> transaksi = await collection.get().then((value) =>
    //     value.docs.map((e) => TransaksiModel.fromSnapshot(e)).toList());
    List<TransaksiModel> newTransaksi =
        _transaksi.where((element) => element.nominal != 0).toList();
    List<Map<String, dynamic>> datas = [];
    var newMap = groupBy(newTransaksi, (p0) => p0.donatur!.id);
    newMap.forEach(
      (key, value) {
        int total = 0;
        for (var element in value) {
          total += element.nominal!;
        }
        datas.add({"data": value[0], "total": total});
      },
    );

    datas = datas.sorted((a, b) => b['total'].compareTo(a['total']));
    _topDonaturs = datas.length > 5 ? datas.sublist(0, 5) : datas;

    // notifyListeners();
    return datas;
  }

  Future<List<Map<String, dynamic>>> getTopUserByTotalDonasi() async {
    // List<TransaksiModel> dataInfak = await collection.get().then((value) =>
    //     value.docs.map((e) => TransaksiModel.fromSnapshot(e)).toList());
    List<TransaksiModel> newTransaksi =
        _transaksi.where((element) => element.nominal != 0).toList();

    List<Map<String, dynamic>> datas = [];
    var newMap = groupBy(newTransaksi, (p0) => p0.petugas!.id);
    newMap.forEach((key, value) {
      int total = 0;
      for (var element in value) {
        total += element.nominal!;
      }
      datas.add({"data": value[0], "total": total});
    });
    datas = datas.sorted((a, b) => b['total'].compareTo(a['total']));
    _topUsers = datas.length > 5 ? datas.sublist(0, 5) : datas;
    // notifyListeners();
    return datas;
  }
}
