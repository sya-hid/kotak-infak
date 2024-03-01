import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user = UserModel();
  UserModel get user => _user!;

//
  // AuthProvider(this._user);

  set user(UserModel user) {
    _user = user;
    // notifyListeners();
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String message = '';
    dynamic data;
    StatusType statusType;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      data = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: userCredential.user!.email!)
          .get()
          .then((querySnapshot) =>
              UserModel.fromSnapshot(querySnapshot.docs.first));
      message = 'Login Suksess';
      statusType = StatusType.success;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userPref', jsonEncode(data.toSharedPref()));
      prefs.setBool('loggedIn', true);

      _user = data;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else {
        message = e.code;
      }
      data = null;
      statusType = StatusType.error;
    }
    return Response(status: statusType, data: data, message: message);
  }

  Future<Response> logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('userPref');
    prefs.setBool('loggedIn', false);
    return Response(
        data: null, status: StatusType.success, message: 'Sukses Logout');
  }

  Future<UserModel> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserModel user =
        UserModel.fromSharedPref(jsonDecode(prefs.getString('userPref')!));
    _user = user;
    notifyListeners();
    return _user!;
  }

  Future<Response> updateProfile({required UserModel newData}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(newData.id)
          .set(newData.toJson());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userPref', jsonEncode(newData.toSharedPref()));
      user = newData;
      notifyListeners();
      return Response(
          data: newData,
          status: StatusType.success,
          message: 'Update Data Sukses');
    } catch (e) {
      return Response(
          data: null, status: StatusType.error, message: e.toString());
    }
  }
}
