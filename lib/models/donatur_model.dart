import 'package:cloud_firestore/cloud_firestore.dart';

class DonaturModel {
  String? id;
  String? name;
  String? category;
  String? noHp;
  String? alamat;
  String? email;
  GeoPoint? geopoint;
  Timestamp? createdAt;

  DonaturModel(
      {this.id,
      this.name,
      this.category,
      this.noHp,
      this.alamat,
      this.email,
      this.geopoint,
      this.createdAt});
//dari firebase
  DonaturModel.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot['id'];
    name = snapshot['nama'];
    noHp = snapshot['no_hp'];
    alamat = snapshot['alamat'];
    email = snapshot['email'];
    category = snapshot['category'];
    createdAt = snapshot['created_at'];
    geopoint =
        GeoPoint(snapshot['geopoint'].latitude, snapshot['geopoint'].longitude);
  }
  DonaturModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['nama'] ?? '';
    noHp = json['no_hp'] ?? '';
    alamat = json['alamat'] ?? '';
    email = json['email'] ?? '';
    category = json['category'] ?? '';
    createdAt = json['created_at'] ?? '';
    geopoint = GeoPoint(json['geopoint'].latitude, json['geopoint'].longitude);
  }

//ke firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': name,
      'geopoint': geopoint,
      'alamat': alamat,
      'email': email,
      'no_hp': noHp,
      'category': category,
      'created_at': createdAt,
    };
  }
}
