import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/models/user_model.dart';

class TransaksiModel {
  String? id;
  String? idDonatur;
  DonaturModel? donatur;
  String? idPetugas;
  UserModel? petugas;

  // Map<String, dynamic>? donatur;
  // Map<String, dynamic>? petugas;
  int? nominal;
  String? oleh;
  Timestamp? createdAt;
  TransaksiModel(
      {this.id,
      this.donatur,
      this.idDonatur,
      this.idPetugas,
      this.petugas,
      this.nominal,
      this.oleh,
      this.createdAt});
  TransaksiModel.fromSnapshot(DocumentSnapshot data) {
    id = data['id'] ?? '';
    idDonatur = data['id_donatur'] ?? '';
    idPetugas = data['id_petugas'] ?? '';
    donatur = DonaturModel.fromJson(data['donatur']);
    petugas = petugas;
    petugas = UserModel.fromJson(data['petugas']);
    nominal = data['nominal'] ?? 0;
    oleh = data['oleh'] ?? '';
    createdAt = data['created_at'] ?? Timestamp.now();
  }
  TransaksiModel.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    idDonatur = data['id_donatur'] ?? '';
    idPetugas = data['id_petugas'] ?? '';
    donatur = DonaturModel.fromJson(data['donatur']);
    petugas = UserModel.fromJson(data['petugas']);
    nominal = data['nominal'] ?? 0;
    oleh = data['oleh'];
    createdAt = data['created_at'];
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_donatur': idDonatur,
      'donatur': donatur!.toJson(),
      'petugas': petugas!.toJson(),
      'id_petugas': idPetugas,
      'nominal': nominal,
      'oleh': oleh,
      'created_at': createdAt,
    };
  }
}
