import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/pages/add_donatur_page.dart';
import 'package:kotak_infak/pages/detail_donatur_page.dart';
import 'package:kotak_infak/pages/petugas/history_page.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/provider/donatur_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListDonaturPage extends StatefulWidget {
  const ListDonaturPage({super.key});

  @override
  State<ListDonaturPage> createState() => _ListDonaturPageState();
}

class _ListDonaturPageState extends State<ListDonaturPage> {
  @override
  Widget build(BuildContext context) {
    DonaturProvider donaturProvider = Provider.of<DonaturProvider>(context);
    donaturProvider.allDonatur();
    List<TransaksiModel> dataTransaksi = donaturProvider.donaturs;

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: 'Add Donatur',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddDonaturPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  List<Map<String, dynamic>> searchTerms = [];
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  //  List<Map<String,dynamic>> newListHistory = prefs.getStringList(
                  //         'prefListDonatur') ??
                  //     [];
                  List<Map<String, dynamic>> newListHistory = [];

                  for (var element in dataTransaksi) {
                    searchTerms.add({
                      'text1': element.donatur!.name,
                      'text2': element.createdAt,
                    });
                  }

                  var result = await showSearch(
                      context: context,
                      delegate: NewCustomSearchDelegate(
                          searchHistory: [], datatransaksi: searchTerms));

                  if (result != null) {
                    if (!newListHistory.contains(result)) {
                      newListHistory.add(result);
                      print('add history $result');
                    }
                    print(newListHistory[newListHistory.length - 1]['text1']);
                    print(newListHistory[newListHistory.length - 1]['text2']);
                  }
                  // prefs.setString('prefListDonatur', jsonEncode(result.toSharedPref()));
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ))
          ],
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: donaturProvider.allDonatur,
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
                          builder: (context) =>
                              DetailDonaturPage(transaksi: data)));
                },
                child: HistoryDonaturItem(data: data),
              );
            },
          ),
        ));
  }
}

// class SearchAppbar extends StatefulWidget {
//   const SearchAppbar({super.key});

//   @override
//   State<SearchAppbar> createState() => _SearchAppbarState();
// }

// class _SearchAppbarState extends State<SearchAppbar> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           IconButton(
//               onPressed: () async {
//                 var result = await showSearch(
//                     context: context,
//                     delegate: CustomSearchDelegate(
//                       datatransaksi: da
//                     ),
//                     query: '',
//                     useRootNavigator: true);
//                 print('hasil');
//                 print(result);
//               },
//               icon: const Icon(Icons.search))
//         ],
//       ),
//     );
//   }
// }

class CustomSearchDelegate extends SearchDelegate {
  final List<String> datatransaksi;
  final List<String> searchHistory;
  CustomSearchDelegate({
    super.searchFieldLabel,
    super.searchFieldStyle,
    super.searchFieldDecorationTheme,
    super.keyboardType,
    super.textInputAction,
    required this.searchHistory,
    required this.datatransaksi,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    List<String> matchsearchHistory = [];

    for (var item in datatransaksi) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    for (var item in searchHistory) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchsearchHistory.add(item);
      }
    }
    return ListView(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: matchsearchHistory.length,
          itemBuilder: (context, index) {
            var result = searchHistory[index];
            return GestureDetector(
                onTap: () {
                  print('searchHistry');
                  print(result);
                  query = result;

                  close(context, result);
                },
                child: ListTile(
                    leading: const Icon(Icons.history), title: Text(result)));
          },
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: matchQuery.length,
          itemBuilder: (context, index) {
            var result = matchQuery[index];
            return GestureDetector(
                onTap: () {
                  print('result');
                  print(result);
                  query = result;

                  close(context, result);
                },
                child: ListTile(
                    leading: const Icon(Icons.search), title: Text(result)));
          },
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    List<String> matchSearchHistory = [];

    for (var item in datatransaksi) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    for (var item in searchHistory) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchSearchHistory.add(item);
      }
    }
    return ListView(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: matchSearchHistory.length,
          itemBuilder: (context, index) {
            var result = matchSearchHistory[index];
            return GestureDetector(
                onTap: () {
                  print('searchHistry');
                  print(result);
                  query = result;
                  if (!matchSearchHistory.contains(result)) {
                    matchSearchHistory.add(result);
                  }
                  close(context, result);
                },
                child: ListTile(
                    leading: const Icon(Icons.history), title: Text(result)));
          },
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: matchQuery.length,
          itemBuilder: (context, index) {
            var result = matchQuery[index];
            return GestureDetector(
                onTap: () {
                  print('sugestion');
                  print(result);
                  query = result;
                  if (!searchHistory.contains(result)) {
                    searchHistory.add(result);
                    print(searchHistory.length);
                    print('add history $result');
                  }
                  close(context, result);
                },
                child: ListTile(
                    leading: const Icon(Icons.search), title: Text(result)));
          },
        )
      ],
    );
  }
}

class NewCustomSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> datatransaksi;
  final List<Map<String, dynamic>> searchHistory;
  NewCustomSearchDelegate({
    super.searchFieldLabel,
    super.searchFieldStyle,
    super.searchFieldDecorationTheme,
    super.keyboardType,
    super.textInputAction,
    required this.searchHistory,
    required this.datatransaksi,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];
    List<Map<String, dynamic>> matchsearchHistory = [];

    for (var item in datatransaksi) {
      if (item['text1'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    for (var item in searchHistory) {
      if (item['text1'].toLowerCase().contains(query.toLowerCase())) {
        matchsearchHistory.add(item);
      }
    }
    return ListView(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: matchsearchHistory.length,
          itemBuilder: (context, index) {
            var result = searchHistory[index];
            return GestureDetector(
                onTap: () {
                  print('searchHistry');
                  print(result);
                  query = result['text1'];

                  close(context, result);
                },
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(result['text1']),
                  subtitle: Text(DateFormat('EEEE, dd-MMMM-yyyy HH:mm', 'id_ID')
                      .format(result['text2'].toDate())),
                ));
          },
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: matchQuery.length,
          itemBuilder: (context, index) {
            var result = matchQuery[index];
            return GestureDetector(
                onTap: () {
                  print('result');
                  print(result);
                  query = result['text1'];

                  close(context, result);
                },
                child: ListTile(
                  leading: const Icon(Icons.search),
                  title: Text(result['text1']),
                  subtitle: Text(DateFormat('EEEE, dd-MMMM-yyyy HH:mm', 'id_ID')
                      .format(result['text2'].toDate())),
                ));
          },
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];
    List<Map<String, dynamic>> matchSearchHistory = [];

    for (var item in datatransaksi) {
      if (item['text1'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    for (var item in searchHistory) {
      if (item['text1'].toLowerCase().contains(query.toLowerCase())) {
        matchSearchHistory.add(item);
      }
    }
    return ListView(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: matchSearchHistory.length,
          itemBuilder: (context, index) {
            var result = matchSearchHistory[index];
            return GestureDetector(
                onTap: () {
                  print('searchHistry');
                  print(result);
                  query = result['text1'];

                  close(context, result);
                },
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(result['text1']),
                  subtitle: Text(DateFormat('EEEE, dd-MMMM-yyyy HH:mm', 'id_ID')
                      .format(result['text2'].toDate())),
                ));
          },
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: matchQuery.length,
          itemBuilder: (context, index) {
            var result = matchQuery[index];
            return GestureDetector(
                onTap: () {
                  print('sugestion');
                  print(result);
                  query = result['text1'];
                  close(context, result);
                },
                child: ListTile(
                  leading: const Icon(Icons.search),
                  title: Text(result['text1']),
                  // subtitle: Text(result['text2']),
                  subtitle: Text(DateFormat('EEEE, dd-MMMM-yyyy HH:mm', 'id_ID')
                      .format(result['text2'].toDate())),
                ));
          },
        )
      ],
    );
  }
}
