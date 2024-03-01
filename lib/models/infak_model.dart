import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/models/user_model.dart';

class InfakModel {
  String? id;
  DonaturModel? donatur;
  UserModel? petugas;
  int? nominal;
  String? diserahkanOleh;
  Timestamp? createdAt;

  InfakModel(
      {this.id,
      this.donatur,
      this.petugas,
      this.nominal,
      this.diserahkanOleh,
      this.createdAt});
//ke firebase
  Map<String, dynamic> toJson() {
    return {
      'nominal': nominal,
      'donatur': donatur,
      'diserahkan_oleh': diserahkanOleh,
      'petugas': petugas,
      'created_at': createdAt,
    };
  }
}
