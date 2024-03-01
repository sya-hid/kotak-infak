import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/category_model.dart';
import 'package:kotak_infak/models/transaksi_model.dart';

class CategoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  List<CategoryModel> _kategori = [];
  List<CategoryModel> get kategori => _kategori;

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('category');
  Future<List<Map<String, dynamic>>> allData() async {
    List<TransaksiModel> datas = await FirebaseFirestore.instance
        .collection('transaksi')
        .get()
        .then((value) =>
            value.docs.map((e) => TransaksiModel.fromSnapshot(e)).toList());
    List<TransaksiModel> transaction =
        datas.where((element) => element.nominal != 0).toList();
    List<TransaksiModel> donaturs =
        datas.where((element) => element.nominal == 0).toList();

    List<CategoryModel> categories = await collection.get().then((value) =>
        value.docs.map((e) => CategoryModel.fromSnapshot(e)).toList());
    List<Map<String, dynamic>> newCategories = [];
    for (var element in categories) {
      newCategories.add({
        'data': element,
        'total_donasi': getTotal(element.category!, transaction),
        'total_donatur': totalDonatur(element.category!, donaturs),
      });
    }
    _categories = newCategories;
    return newCategories;
  }

  Future<List<CategoryModel>> allCategory() async {
    List<CategoryModel> categories = await collection.get().then((value) =>
        value.docs.map((e) => CategoryModel.fromSnapshot(e)).toList());
    _kategori = categories;
    notifyListeners();
    return categories;
  }

  Future<Response> createData(String docId, CategoryModel data) async {
    collection.doc(docId).set(data.toJson());
    return Response(
        data: null,
        status: StatusType.success,
        message: '${data.category} Ditambahkan');
  }
}

getTotal(String kategori, List<TransaksiModel> transaction) {
  int total = 0;
  for (var element in transaction) {
    if (element.donatur!.category == kategori) {
      total += element.nominal!;
    }
  }
  return total;
}

totalDonatur(String kategori, List<TransaksiModel> donaturs) {
  int total = 0;
  for (var element in donaturs) {
    if (element.donatur!.category == kategori) {
      total += 1;
    }
  }
  return total;
}
