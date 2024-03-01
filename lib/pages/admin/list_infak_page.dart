import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/pages/print_infak_page.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class ListInfakPage extends StatefulWidget {
  const ListInfakPage({super.key});

  @override
  State<ListInfakPage> createState() => _ListInfakPageState();
}

class _ListInfakPageState extends State<ListInfakPage> {
  List<TransaksiModel> transaksi = [];
  bool hasConnection = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    transactionProvider.allData();
    List<TransaksiModel> dataTransaksi = transactionProvider.transaksi
        .where((element) => element.nominal != 0)
        .sorted((a, b) => b.createdAt!.compareTo(a.createdAt!))
        .toList();

    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: transactionProvider.allData,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: dataTransaksi.length,
          itemBuilder: (context, index) {
            TransaksiModel data = dataTransaksi[index];
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
        ),
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
                  Text('${data.donatur!.name} (${data.donatur!.category!})',
                      // '${data.petugas!.name}',
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    data.donatur!.alamat!,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14),
                  ),
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
