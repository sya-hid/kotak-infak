import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String? id;
  String? category;
  Timestamp? createdAt;

  CategoryModel({this.category, required this.createdAt});
  CategoryModel.fromSnapshot(DocumentSnapshot json) {
    id = json['id'];
    category = json['category'];
    createdAt = json['created_at'];
  }
  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'created_at': createdAt,
    };
  }
}
