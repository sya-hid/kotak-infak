import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/user_model.dart';

class UsersProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> get users => _users;
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('user');
  set users(List<UserModel> users) {
    _users = users;
    notifyListeners();
  }

  Future<List<UserModel>> allUser() async {
    List<UserModel> data = await collection.get().then(
        (value) => value.docs.map((e) => UserModel.fromSnapshot(e)).toList());

    _users =
        data.sorted((a, b) => b.createdAt!.compareTo(a.createdAt!)).toList();
    notifyListeners();
    return users;
  }

  Future<Response> addUser(String id, UserModel user, DateTime dateTime) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String message = '';
    dynamic data;
    StatusType status;
    try {
      // add user auth
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: user.email!,
          password: DateFormat('yyyyMMdd').format(dateTime));
      if (userCredential.user != null) {
        //add user
        await collection.doc(id).set(user.toJson());
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

    return Response(data: data, status: status, message: message);
  }

  Future<Response> update(String id, UserModel user) async {
    await collection.doc(id).set(user.toJson());
    return Response(
        data: user, status: StatusType.success, message: 'Update User Sukses');
  }
}
