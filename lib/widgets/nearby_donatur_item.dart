import 'package:flutter/material.dart';
import 'package:kotak_infak/models/transaksi_model.dart';

class NerByDonaturItem extends StatelessWidget {
  const NerByDonaturItem({
    super.key,
    required this.transaksi,
    required this.distance,
  });

  final TransaksiModel transaksi;
  final int distance;

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
                    transaksi.donatur!.name!,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    transaksi.donatur!.alamat!,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$distance m',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
