import 'package:flutter/material.dart';
import 'package:kotak_infak/pages/history_by_donatur.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:kotak_infak/widgets/top_donatur_item.dart';
import 'package:provider/provider.dart';

class TopDonaturs extends StatelessWidget {
  const TopDonaturs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    transactionProvider.getTopDonaturByTotalDonasi();

    List<Map<String, dynamic>> listTopDonatur = transactionProvider.topDonaturs;

    return RefreshIndicator.adaptive(
      onRefresh: () => transactionProvider.getTopDonaturByTotalDonasi(),
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: listTopDonatur.isNotEmpty
          ? ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: listTopDonatur.length,
              itemBuilder: (context, index) {
                TransaksiModel data = listTopDonatur[index]['data'];
                int total = listTopDonatur[index]['total'];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryByDonatur(
                          idDonatur: data.donatur!.id!,
                          donaturName: data.donatur!.name!,
                        ),
                      ),
                    );
                  },
                  child: TopDonaturItem(data: data, total: total),
                );
              },
            )
          : const Center(
              child: Text('Belum Ada Data'),
            ),
    );
  }
}
