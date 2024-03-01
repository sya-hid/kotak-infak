import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/consts.dart';
import 'package:kotak_infak/pages/print_donatur_page.dart';
import 'package:kotak_infak/pages/print_infak_page.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/models/user_model.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/theme_provider.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> tabs = ['Donatur', 'Infak'];
  @override
  Widget build(BuildContext context) {
    // UserProvider userProvider = Provider.of<UserProvider>(context);
    // UserModel user = userProvider.getUser();
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;
    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    ThemeNotifier theme = Provider.of<ThemeNotifier>(context);
    transactionProvider.allData();
    transactionProvider.getHistoryDonaturByUser(user.id!);
    transactionProvider.getHistoryInfakByUser(user.id!);
    List<TransaksiModel> historyDonaturByUser =
        transactionProvider.historyDonaturByUser;
    List<TransaksiModel> historyInfakByUser =
        transactionProvider.historyInfakByUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: false,
                    labelColor: theme.getThemeMode() == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                    tabs: [
                      ...List.generate(
                        tabs.length,
                        (index) => Tab(
                          text: tabs[index],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(children: [
                      RefreshIndicator(
                          triggerMode: RefreshIndicatorTriggerMode.anywhere,
                          child: historyDonaturByUser.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.all(10),
                                  itemBuilder: (context, index) {
                                    final TransaksiModel data =
                                        historyDonaturByUser[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PrintDonaturPage(
                                                        transaksi: data)));
                                      },
                                      child: HistoryDonaturItem(data: data),
                                    );
                                  },
                                  itemCount: historyDonaturByUser.length)
                              : const Center(child: Text('Belum Ada Data')),
                          onRefresh: () => transactionProvider
                              .getHistoryDonaturByUser(authProvider.user.id!)),
                      RefreshIndicator.adaptive(
                          triggerMode: RefreshIndicatorTriggerMode.anywhere,
                          child: historyInfakByUser.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  itemBuilder: (context, index) {
                                    final TransaksiModel data =
                                        historyInfakByUser[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailInfak(
                                                        transaksi: data)));
                                      },
                                      child: HistoryInfakItem(data: data),
                                    );
                                  },
                                  itemCount: historyInfakByUser.length)
                              : const Center(
                                  child: Text('Belum Ada Data'),
                                ),
                          onRefresh: () => transactionProvider
                              .getHistoryInfakByUser(authProvider.user.id!))
                    ]),
                  )
                ],
              ),
            ),
          ),
        ],
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
                      '${data.donatur!.name ?? "nama"} (${data.donatur!.category!})',
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

class HistoryDonaturItem extends StatelessWidget {
  const HistoryDonaturItem({
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
                  data.donatur!.name!,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(data.donatur!.alamat!, maxLines: 2),
                const SizedBox(height: 5),
                Text(DateFormat('EEEE, dd-MMMM-yyyy HH:mm', 'id_ID')
                    .format(data.createdAt!.toDate()))
              ],
            ))
          ],
        ),
      ),
    );
  }
}
