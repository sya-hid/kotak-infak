import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? name;
  String? email;
  String? noHp;
  String? password;
  String? level;
  String? alamat;
  String? tempatLahir;
  String? profileUrl;

  Timestamp? tanggalLahir;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.noHp,
    this.level,
    this.alamat,
    this.tanggalLahir,
    this.profileUrl,
    this.tempatLahir,
    this.createdAt,
    this.updatedAt,
  });
  UserModel.fromSnapshot(DocumentSnapshot data) {
    id = data['id'] ?? '';
    name = data['name'] ?? '';
    email = data['email'] ?? '';
    alamat = data['alamat'] ?? '';
    noHp = data['no_hp'] ?? '';
    password = data['password'] ?? '';
    tanggalLahir = data['tanggal_lahir'] ?? '';
    level = data['level'] ?? '';
    tempatLahir = data['tempat_lahir'] ?? '';
    profileUrl = data['profile_url'] ?? 'https://i.imgur.com/sUFH1Aq.png';
    createdAt = data['created_at'];
    updatedAt = data['updated_at'];
  }
  UserModel.fromQuerySnapshot(QueryDocumentSnapshot data) {
    id = data['id'] ?? '';
    name = data['name'] ?? '';
    email = data['email'] ?? '';
    alamat = data['alamat'] ?? '';
    noHp = data['no_hp'] ?? '';
    password = data['password'] ?? '';
    tanggalLahir = data['tanggal_lahir'] ?? '';
    level = data['level'] ?? '';
    profileUrl = data['profile_url'] ?? '';
    tempatLahir = data['tempat_lahir'] ?? '';
    createdAt = data['created_at'];
    updatedAt = data['updated_at'];
  }
  UserModel.fromJson(Map<String, dynamic> data) {
    id = data['id'] ?? '';

    name = data['name'] ?? '';
    email = data['email'] ?? '';
    alamat = data['alamat'] ?? '';
    noHp = data['no_hp'] ?? '';
    level = data['level'] ?? '';
    password = data['password'] ?? '';
    tanggalLahir = data['tanggal_lahir'] ?? '';
    profileUrl = data['profile_url'] ?? '';
    tempatLahir = data['tempat_lahir'] ?? '';
    createdAt = data['created_at'];
    updatedAt = data['updated_at'];
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'alamat': alamat,
      'level': level,
      'no_hp': noHp,
      'password': password,
      'profile_url': profileUrl,
      'tanggal_lahir': tanggalLahir,
      'tempat_lahir': tempatLahir,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserModel.fromSharedPref(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    email = data['email'];
    alamat = data['alamat'];
    noHp = data['no_hp'];
    password = data['password'];
    profileUrl = data['profile_url'];
    tanggalLahir = Timestamp.fromMillisecondsSinceEpoch(data['tanggal_lahir']);
    level = data['level'];
    tempatLahir = data['tempat_lahir'];
    createdAt = Timestamp.fromMillisecondsSinceEpoch(data['created_at']);
    updatedAt = Timestamp.fromMillisecondsSinceEpoch(data['updated_at']);
  }
  Map<String, dynamic> toSharedPref() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'alamat': alamat,
      'level': level,
      'no_hp': noHp,
      'password': password,
      'profile_url': profileUrl,
      'tanggal_lahir': tanggalLahir!.millisecondsSinceEpoch,
      'tempat_lahir': tempatLahir,
      'created_at': createdAt!.millisecondsSinceEpoch,
      'updated_at': updatedAt!.millisecondsSinceEpoch,
    };
  }
}
