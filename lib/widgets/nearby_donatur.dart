import 'package:flutter/material.dart';
import 'package:kotak_infak/pages/detail_donatur_page.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:kotak_infak/widgets/nearby_donatur_item.dart';
import 'package:provider/provider.dart';

class NearbyDonatur extends StatelessWidget {
  const NearbyDonatur({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    transactionProvider.getNearByDonatur();
    List<Map<String, dynamic>> nearByDonatur =
        transactionProvider.nearByDonaturs;
    return RefreshIndicator.adaptive(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () => transactionProvider.getNearByDonatur(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        clipBehavior: Clip.none,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: nearByDonatur.length,
        itemBuilder: (context, index) {
          TransaksiModel transaksi = nearByDonatur[index]['data'];
          int distance = nearByDonatur[index]['distance'].toInt();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailDonaturPage(
                    transaksi: transaksi,
                  ),
                ),
              );
            },
            child: NerByDonaturItem(transaksi: transaksi, distance: distance),
          );
        },
      ),
    );
  }
}
