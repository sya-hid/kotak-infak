import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kotak_infak/pages/admin/main_page.dart';
import 'package:kotak_infak/pages/login_page.dart';
import 'package:kotak_infak/pages/petugas/history_page.dart';
import 'package:kotak_infak/pages/petugas/main_page.dart';
import 'package:kotak_infak/models/donatur_model.dart';
import 'package:kotak_infak/models/transaksi_model.dart';
import 'package:kotak_infak/models/user_model.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/bluetooth_provider.dart';
import 'package:kotak_infak/provider/category_provider.dart';
import 'package:kotak_infak/provider/donatur_provider.dart';
import 'package:kotak_infak/provider/instansi_provider.dart';
import 'package:kotak_infak/provider/network_provider.dart';
import 'package:kotak_infak/provider/page_provider.dart';
import 'package:kotak_infak/provider/transaction_provider.dart';
import 'package:kotak_infak/provider/user_provider.dart';
import 'package:kotak_infak/provider/position_provider.dart';
import 'package:kotak_infak/provider/theme_provider.dart';
import 'package:kotak_infak/utils/app_theme.dart';
import 'package:kotak_infak/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:random_x/random_x.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyA3nd2nz_RHZE9ZJ4LA2FBakl4KIBO41i4',
        appId: '1:928150354762:android:7ddc097f40adaee79b9fb3',
        messagingSenderId: 'messagingSenderId',
        projectId: 'kotak-infak',
        storageBucket: 'kotak-infak.appspot.com'),
  );
  initializeDateFormatting();
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.landscapeLeft, DeviceOrientation.portraitUp]);

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then((value) {
    runApp(ChangeNotifierProvider(
        create: (context) => ThemeNotifier(ThemeMode.light),
        child: const MyApp()));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = false;
  UserModel? user;
  init() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.getBool('loggedIn') ?? false;
    if (loggedIn) {
      user = UserModel.fromSharedPref(jsonDecode(prefs.getString('userPref')!));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MultiProvider(
      providers: [
        StreamProvider(
            create: (context) => NetworkService().controller.stream,
            initialData: NetworkStatus.online),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => PageProvider()),
        ChangeNotifierProvider(create: (context) => InstansiProvider()),
        ChangeNotifierProvider(create: (context) => BluetoothProvider()),
        ChangeNotifierProvider(create: (context) => PositionProvider()),
        ChangeNotifierProvider(create: (context) => DonaturProvider()),
        ChangeNotifierProvider(create: (context) => UsersProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider())
      ],
      child: MaterialApp(
        title: 'Kotak Infak App',
        theme: AppTheme().lightTheme,
        darkTheme: AppTheme().darkTheme,
        debugShowCheckedModeBanner: false,
        themeMode: themeNotifier.getThemeMode(),
        // home: const ListDonaturPage(),
        home: loggedIn
            ? user!.id != null
                ? MainPage(userModel: user!)
                : const CircularProgressIndicator()
            : const LoginPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final UserModel userModel;
  const MainPage({super.key, required this.userModel});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    var network = Provider.of<NetworkStatus>(context);
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    // authProvider.user = widget.userModel;
    // print(authProvider.user.name);
    authProvider.getUser();
    return Scaffold(
        body: network == NetworkStatus.online
            ? widget.userModel.id != null
                ? widget.userModel.level == 'Admin'
                    ? const MainPageAdmin()
                    : const MainPagePetugas()
                : const Center(child: CircularProgressIndicator())
            : const Center(child: Text('Tidak Terkoneksi Internet')));
  }
}

class PageAdmin extends StatelessWidget {
  const PageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    DonaturProvider donaturProvider = Provider.of<DonaturProvider>(context);
    TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          const Text('Page Admin'),
          CustomButton(
              onTap: () async {
                final Timestamp createdAt = Timestamp.now();
                String name = RndX.generateName();
                String email = RndX.generateEmail();
                String alamat = RndX.generateRandomStreetAddress();
                RndX.generateRandomLatitude();
                String noHp = RndX.generatePhoneNumber();
                var id = DateFormat('yyMMddHHmmss').format(createdAt.toDate());
                DonaturModel donatur = DonaturModel(
                    id: id,
                    alamat: alamat,
                    category: 'currentCategory',
                    geopoint: GeoPoint(RndX.generateRandomLatitude(),
                        RndX.generateRandomLongitude()),
                    name: name,
                    noHp: noHp,
                    email: email,
                    createdAt: createdAt);
                TransaksiModel transaksi = TransaksiModel(
                    id: id,
                    donatur: donatur,
                    petugas: UserModel(),
                    idDonatur: donatur.id,
                    idPetugas: 'currentUser.id',
                    nominal: 0,
                    oleh: RndX.generateName(),
                    createdAt: createdAt);

                await donaturProvider.createData(id, DonaturModel());
                await transactionProvider.createData(id, transaksi);
              },
              text: 'Generate Donatur')
        ],
      ),
    );
  }
}

class PagePetugas extends StatelessWidget {
  const PagePetugas({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Page Petugas'),
      ),
    );
  }
}

class TestConnection extends StatefulWidget {
  const TestConnection({super.key});

  @override
  State<TestConnection> createState() => _TestConnectionState();
}

class _TestConnectionState extends State<TestConnection> {
  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('transaksi')
        // .where('nominal', isNotEqualTo: 0)
        // .where('id_petugas', isEqualTo: idUser)
        .withConverter(
            fromFirestore: (snapshot, options) =>
                TransaksiModel.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson());
    return Scaffold(
        appBar: AppBar(),
        body: FirestoreQueryBuilder(
          query: query,
          pageSize: 10,
          builder: (context, snapshot, child) {
            return ListView.builder(
              itemCount: snapshot.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                  snapshot.fetchMore();
                }
                final TransaksiModel data = snapshot.docs[index].data();
                return HistoryInfakItem(data: data);
              },
            );
          },
        )
        // FirestoreListView<TransaksiModel>(
        //   query: query,
        //   pageSize: 5,
        //   itemBuilder: (context, doc) {
        //     final TransaksiModel data = doc.data();

        //     return GestureDetector(
        //       onTap: () {

        //       },
        //       child: HistoryInfakItem(data: data),
        //     );
        //   },
        // ),
        );
  }
}

class DummyData extends StatefulWidget {
  const DummyData({super.key});

  @override
  State<DummyData> createState() => _DummyDataState();
}

class _DummyDataState extends State<DummyData> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    List<String> data = await FirebaseFirestore.instance
                        .collection('category')
                        .get()
                        .then((value) => value.docs.map((e) => e.id).toList());
                    for (var i = 0; i < data.length; i++) {
                      await FirebaseFirestore.instance
                          .collection('category')
                          .doc(data[i])
                          .delete();
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  text: 'Clear Data')
        ],
      ),
    );
  }
}
