import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/pages/print_infak_page.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class HistoryByDonatur extends StatelessWidget {
  const HistoryByDonatur(
      {super.key, required this.idDonatur, required this.donaturName});
  final String idDonatur;
  final String donaturName;
  @override
  Widget build(BuildContext context) {
    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    transactionProvider.getHistoryInfakByDonatur(idDonatur);
    List<TransaksiModel> historyByDonatur =
        transactionProvider.historyInfakByDonatur;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          donaturName,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            transactionProvider.getHistoryInfakByDonatur(idDonatur),
        child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final TransaksiModel data = historyByDonatur[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailInfak(transaksi: data),
                    ),
                  );
                },
                child: HistoryInfakItem(data: data),
              );
            },
            itemCount: historyByDonatur.length),
      ),
    );
  }
}

class HistoryInfakItem extends StatelessWidget {
  const HistoryInfakItem({
    super.key,
    required this.data,
  });

  final TransaksiModel data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      // '${data.donatur!.name ?? "nama"} (${data.donatur!.category!})',
                      '${data.petugas!.name}',
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 5),
                  // Text(
                  //   data.donatur!.alamat!,
                  //   maxLines: 2,
                  //   style: const TextStyle(fontSize: 14),
                  // ),
                  const SizedBox(height: 5),
                  Text(DateFormat('EEEE, dd-MMM-yyyy HH:mm', 'id_ID')
                      .format(data.createdAt!.toDate()))
                ],
              ),
            ),
            const SizedBox(width: 15),
            Text(
              currencyFormatter.format(data.nominal),
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
