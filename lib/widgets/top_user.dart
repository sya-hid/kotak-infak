import 'package:flutter/material.dart';
import 'package:kotak_infak/pages/history_by_user.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:kotak_infak/widgets/top_user_item.dart';
import 'package:provider/provider.dart';

class TopUsers extends StatelessWidget {
  const TopUsers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    transactionProvider.getTopUserByTotalDonasi();
    List<Map<String, dynamic>> listTopUsers = transactionProvider.topUsers;

    return RefreshIndicator.adaptive(
      onRefresh: () => transactionProvider.getTopUserByTotalDonasi(),
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: listTopUsers.isNotEmpty
          ? ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: listTopUsers.length,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              clipBehavior: Clip.none,
              // scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                TransaksiModel transaksi = listTopUsers[index]['data'];
                int total = listTopUsers[index]['total'];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryByUser(
                          idUser: transaksi.petugas!.id!,
                          userName: transaksi.petugas!.name!,
                        ),
                      ),
                    );
                  },
                  child: TopUserItem(transaksi: transaksi, total: total),
                );
              },
            )
          : const Center(
              child: Text('Belum Ada Data'),
            ),
    );
  }
}
