import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const font = TextStyle(fontFamily: 'OpenSans');
NumberFormat currencyFormatter = NumberFormat.compactCurrency(
  locale: 'id_ID',
  symbol: 'Rp. ',
  decimalDigits: 2,
);

enum StatusType { success, error }

class Response {
  final dynamic data;
  final String? message;
  final StatusType? status;

  Response({this.data, this.message, this.status});
}
