import 'package:flutter/material.dart';
import 'package:kotak_infak/pages/petugas/history_page.dart';
import 'package:kotak_infak/pages/home_page.dart';
import 'package:kotak_infak/pages/petugas/qr_scanner_page.dart';
import 'package:kotak_infak/provider/page_provider.dart';
import 'package:provider/provider.dart';

class MainPagePetugas extends StatefulWidget {
  const MainPagePetugas({super.key});

  @override
  State<MainPagePetugas> createState() => _MainPagePetugasState();
}

class _MainPagePetugasState extends State<MainPagePetugas> {
  @override
  Widget build(BuildContext context) {
    PageProvider pageProvider = Provider.of<PageProvider>(context);
    Widget body() {
      switch (pageProvider.currentIndex) {
        case 0:
          return const HomePage();
        case 2:
          return const HistoryPage();
        default:
          return const HomePage();
      }
    }

    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: 'Scanner',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScannerPage(),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
      body: body(),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        onTap: (value) {
          if (value != 1) {
            pageProvider.currentIndex = value;
          }
        },
        currentIndex: pageProvider.currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.transparent,
              ),
              label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: ''),
        ],
      ),
    );
  }
}
