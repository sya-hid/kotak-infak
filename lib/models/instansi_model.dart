import 'package:cloud_firestore/cloud_firestore.dart';

class InstansiModel {
  String? id, name, alamat, noHp, email, profileUrl;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  InstansiModel({
    this.id,
    this.name,
    this.alamat,
    this.noHp,
    this.email,
    this.createdAt,
    this.profileUrl,
    this.updatedAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alamat': alamat,
      'no_hp': noHp,
      'email': email,
      'created_at': createdAt!,
      'profile_url': profileUrl,
      'updated_at': updatedAt,
    };
  }

  InstansiModel.fromSnapshot(DocumentSnapshot data) {
    id = data['id'] ?? '';
    name = data['name'] ?? '';
    email = data['email'] ?? '';
    alamat = data['alamat'] ?? '';
    noHp = data['no_hp'] ?? '';
    profileUrl = data['profile_url'] ?? 'https://i.imgur.com/sUFH1Aq.png';
    createdAt = data['created_at'];
    updatedAt = data['updated_at'];
  }
}
