import 'package:flutter/material.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/models/transaksi_model.dart';

class TopDonaturItem extends StatelessWidget {
  const TopDonaturItem({
    super.key,
    required this.data,
    required this.total,
  });

  final TransaksiModel data;
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
                    '${data.donatur!.name!} (${data.donatur!.category!})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(data.donatur!.alamat!),
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
