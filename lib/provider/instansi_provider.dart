import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/instansi_model.dart';

class InstansiProvider extends ChangeNotifier {
  InstansiModel get instansi => _instansi!;
  InstansiModel? _instansi = InstansiModel();

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('instansi');
  set instansi(InstansiModel instansi) {
    _instansi = instansi;
    notifyListeners();
  }

  Future<Response> updateIntansi(String docId, InstansiModel data) async {
    await collection.doc(docId).set(data.toJson());

    _instansi = data;

    notifyListeners();
    return Response(
        data: data, status: StatusType.success, message: 'Update Data Sukses');
  }

  getData() async {
    InstansiModel instansni = await collection
        .get()
        .then((value) => InstansiModel.fromSnapshot(value.docs.first));
    _instansi = instansni;
    notifyListeners();
    return instansni;
  }
}
