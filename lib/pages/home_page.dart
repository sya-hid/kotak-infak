import 'package:flutter/material.dart';
import 'package:kotak_infak/pages/add_donatur_page.dart';
import 'package:kotak_infak/pages/login_page.dart';
import 'package:kotak_infak/pages/profile_page.dart';
import 'package:kotak_infak/pages/setting_page.dart';
import 'package:kotak_infak/models/instansi_model.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/instansi_provider.dart';
import 'package:kotak_infak/provider/theme_provider.dart';
import 'package:kotak_infak/widgets/chart.dart';
import 'package:kotak_infak/widgets/nearby_donatur.dart';
import 'package:kotak_infak/widgets/top_donatur.dart';
import 'package:kotak_infak/widgets/top_user.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dataBy = 'donatur';
  List<String> options = ['Profile', 'Settings', 'Logout'];

  @override
  Widget build(BuildContext context) {
    InstansiProvider instansiProvider = Provider.of<InstansiProvider>(context);

    InstansiModel instansiModel = instansiProvider.instansi;

    ThemeNotifier theme = Provider.of<ThemeNotifier>(context);
    AuthProvider? authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: authProvider.user.level == "Admin"
          ? null
          : authProvider.user.id != null
              ? AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome', style: TextStyle(fontSize: 12)),
                      Text(
                        authProvider.user.name!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  leading: Center(
                    child: instansiModel.profileUrl != null
                        ? CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                instansiModel.profileUrl!))
                        : null,
                  ),
                  actions: [
                    PopupMenuButton(
                      elevation: 3.2,
                      onSelected: (value) async {
                        if (value == 'Profile') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePagePetugas(user: authProvider.user),
                            ),
                          );
                        } else if (value == 'Settings') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingPage(),
                            ),
                          );
                        } else if (value == 'Logout') {
                          // Response response =
                          await authProvider.logout();

                          // final SnackBar snackBar = SnackBar(
                          //   backgroundColor: response.status == StatusType.error
                          //       ? Colors.red
                          //       : Colors.green,
                          //   elevation: 2,
                          //   content: Text(response.message!),
                          //   duration: const Duration(seconds: 3),
                          //   behavior: SnackBarBehavior.floating,
                          // );
                          if (context.mounted) {
                            // ScaffoldMessenger.of(context)
                            //     .showSnackBar(snackBar);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          }
                        }
                      },
                      onCanceled: () {},
                      itemBuilder: (context) {
                        return options
                            .map(
                              (e) => PopupMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList();
                      },
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            authProvider.user.profileUrl!),
                      ),
                    ),
                    const SizedBox(width: 10)
                  ],
                )
              : null,
      floatingActionButton: authProvider.user.level == 'Admin'
          ? null
          : FloatingActionButton(
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
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        children: [
          const Chart(),

          //tab
          SizedBox(
            height: MediaQuery.of(context).size.height * .5,
            child: DefaultTabController(
              length: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    isScrollable: false,
                    labelColor: theme.getThemeMode() == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                    tabs: const [
                      Tab(
                        text: 'Nearby Donatur',
                      ),
                      Tab(
                        text: 'Top Donatur',
                      ),
                      Tab(
                        text: 'Top User',
                      ),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        //nearby donatur
                        NearbyDonatur(),

                        //top donatur
                        TopDonaturs(),

                        //top user
                        TopUsers(),

                        //all infak
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
