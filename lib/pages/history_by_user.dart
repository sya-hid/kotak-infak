import 'package:flutter/material.dart';
import 'package:kotak_infak/pages/petugas/history_page.dart';
import 'package:kotak_infak/pages/print_infak_page.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class HistoryByUser extends StatelessWidget {
  const HistoryByUser(
      {super.key, required this.idUser, required this.userName});
  final String idUser;
  final String userName;
  @override
  Widget build(BuildContext context) {
    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    transactionProvider.getHistoryInfakByUser(idUser);
    List<TransaksiModel> historyByUser = transactionProvider.historyInfakByUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => transactionProvider.getHistoryInfakByUser(idUser),
        child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final TransaksiModel data = historyByUser[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailInfak(transaksi: data)));
                },
                child: HistoryInfakItem(data: data),
              );
            },
            itemCount: historyByUser.length),
      ),
    );
  }
}
