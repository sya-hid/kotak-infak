import 'package:flutter/material.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/transaksi_model.dart';

class TopUserItem extends StatelessWidget {
  const TopUserItem({
    super.key,
    required this.transaksi,
    required this.total,
  });

  final TransaksiModel transaksi;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaksi.petugas!.name!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(transaksi.petugas!.email!),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              currencyFormatter.format(total),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
