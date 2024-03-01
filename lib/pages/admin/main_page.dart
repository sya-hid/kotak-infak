import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:kotak_infak/models/category_model.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/models/user_model.dart';
import 'package:kotak_infak/pages/admin/instansi_page.dart';
import 'package:kotak_infak/pages/admin/list_donatur_page.dart';
import 'package:kotak_infak/pages/admin/list_infak_page.dart';
import 'package:kotak_infak/pages/admin/list_kategori_page.dart';
import 'package:kotak_infak/pages/admin/list_user_page.dart';
import 'package:kotak_infak/pages/login_page.dart';
import 'package:kotak_infak/pages/home_page.dart';
import 'package:kotak_infak/pages/profile_page.dart';
import 'package:kotak_infak/pages/setting_page.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/category_provider.dart';
import 'package:kotak_infak/provider/donatur_provider.dart';
import 'package:kotak_infak/provider/instansi_provider.dart';
import 'package:kotak_infak/provider/page_provider.dart';
import 'package:kotak_infak/provider/theme_provider.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:kotak_infak/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPageAdmin extends StatefulWidget {
  const MainPageAdmin({super.key});

  @override
  State<MainPageAdmin> createState() => _MainPageAdminState();
}

class _MainPageAdminState extends State<MainPageAdmin> {
  @override
  Widget build(BuildContext context) {
    PageProvider pageProvider = Provider.of<PageProvider>(context);
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    InstansiProvider instansiProvider = Provider.of<InstansiProvider>(context);

    DonaturProvider donaturProvider = Provider.of<DonaturProvider>(context);
    donaturProvider.allDonatur();

    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    transactionProvider.allData();

    UsersProvider usersProvider = Provider.of<UsersProvider>(context);
    usersProvider.allUser();
    CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context);

    categoryProvider.allCategory();
    Widget body() {
      switch (pageProvider.currentPage) {
        case 'Home':
          return const HomePage();
        case 'List User':
          return const ListUserPage();
        case 'List Donatur':
          return const ListDonaturPage();
        case 'List Infak':
          return const ListInfakPage();
        case 'List Kategori':
          return const ListKategoriPage();
        case 'Settings':
          return const SettingPage();
        case 'Profile':
          return ProfilePagePetugas(user: authProvider.user);
        case 'Instansi':
          return InstansiPage(instansi: instansiProvider.instansi);
        case 'About':
          return const Center(child: Text('About'));
        default:
          return const HomePage();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageProvider.currentPage),
        actions: [
          (pageProvider.currentPage == 'List Kategori' ||
                  pageProvider.currentPage == 'List User' ||
                  pageProvider.currentPage == 'List Infak' ||
                  pageProvider.currentPage == 'List Donatur')
              ? IconButton(
                  onPressed: () async {
                    List<String> searchTerms = [];
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    pageProvider.currentPage;
                    //donatur

                    List<TransaksiModel> dataDonatur = donaturProvider.donaturs;
                    //infak

                    List<TransaksiModel> dataInfak = transactionProvider
                        .transaksi
                        .where((element) => element.nominal != 0)
                        .sorted((a, b) => b.createdAt!.compareTo(a.createdAt!))
                        .toList();
                    //user

                    List<UserModel> dataUser = usersProvider.users;
                    //catgory

                    List<CategoryModel> categories = categoryProvider.kategori
                        .sorted((a, b) => b.createdAt!.compareTo(a.createdAt!));

                    print(
                        'pref${(pageProvider.currentPage).replaceAll(' ', '')}');
                    List<String> newListHistory = prefs.getStringList(
                            'pref${(pageProvider.currentPage).replaceAll(' ', '')}') ??
                        [];
                    if (pageProvider.currentPage == 'List Kategori') {
                      searchTerms = categories.map((e) => e.category!).toList();
                    } else if (pageProvider.currentPage == 'List User') {
                      searchTerms = dataUser.map((e) => e.name!).toList();
                    } else if (pageProvider.currentPage == 'List Infak') {
                      searchTerms =
                          dataInfak.map((e) => e.donatur!.name!).toList();
                      searchTerms = searchTerms.toSet().toList();
                    } else if (pageProvider.currentPage == 'List Donatur') {
                      searchTerms =
                          dataDonatur.map((e) => e.donatur!.name!).toList();
                    }
                    var result = await showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(
                            searchHistory: newListHistory,
                            datatransaksi: searchTerms));
                    if (result != null) {
                      if (!newListHistory.contains(result)) {
                        newListHistory.add(result);
                        print('add history $result');
                      }
                    }

                    prefs.setStringList(
                        'pref${(pageProvider.currentPage).replaceAll(' ', '')}',
                        newListHistory);
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ))
              : const SizedBox.shrink()
        ],
      ),
      drawer: buildDrawer(context),
      body: body(),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: const [
        Text(
          'Syarif Hidayatullah © 2023',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

Widget _buildMenuItem(
  PageProvider provider,
  BuildContext context,
  Widget title,
  String routeName,
  String currentRoute, {
  required Function()? onTap,
}) {
  final isSelected = routeName == provider.currentPage;

  return ListTile(
    title: title,
    selected: isSelected,
    onTap: onTap,
  );
}

Drawer buildDrawer(BuildContext context) {
  PageProvider pageProvider = Provider.of<PageProvider>(context);
  AuthProvider authProvider = Provider.of<AuthProvider>(context);
  ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);

  return Drawer(
    child: ListView(
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DottedBorder(
                borderType: BorderType.Circle,
                padding: const EdgeInsets.all(10),
                dashPattern: const [5, 10],
                strokeWidth: 2,
                strokeCap: StrokeCap.round,
                color: themeNotifier.getThemeMode() == ThemeMode.dark
                    ? Colors.white70
                    : Colors.black87,
                child: Center(
                    child: Container(
                  height: 85,
                  width: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          authProvider.user.profileUrl ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 15),
              Text(
                authProvider.user.name ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 14),
              ),
            ],
          ),
        ),
        _buildMenuItem(
          pageProvider,
          context,
          const Text('Home'),
          'Home',
          pageProvider.currentPage,
          onTap: () {
            pageProvider.currentPage = 'Home';
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          pageProvider,
          context,
          const Text('List User'),
          'List User',
          pageProvider.currentPage,
          onTap: () {
            pageProvider.currentPage = 'List User';
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          pageProvider,
          context,
          const Text('List Donatur'),
          'List Donatur',
          pageProvider.currentPage,
          onTap: () {
            pageProvider.currentPage = 'List Donatur';
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          pageProvider,
          context,
          const Text('List Infak'),
          'List Infak',
          pageProvider.currentPage,
          onTap: () {
            pageProvider.currentPage = 'List Infak';
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          pageProvider,
          context,
          const Text('List Kategori'),
          'List Kategori',
          pageProvider.currentPage,
          onTap: () {
            pageProvider.currentPage = 'List Kategori';
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          pageProvider,
          context,
          const Text('Instansi'),
          'Instansi',
          pageProvider.currentPage,
          onTap: () {
            pageProvider.currentPage = 'Instansi';
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          pageProvider,
          context,
          const Text('Profile'),
          'Profile',
          pageProvider.currentPage,
          onTap: () {
            pageProvider.currentPage = 'Profile';
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          pageProvider,
          context,
          const Text('Settings'),
          'Settings',
          pageProvider.currentPage,
          onTap: () {
            pageProvider.currentPage = 'Settings';
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Logout'),
          // selected: isSelected,
          onTap: () async {
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
              // ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            }
          },
        ),
      ],
    ),
  );
}
