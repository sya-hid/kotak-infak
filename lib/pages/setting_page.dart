import 'package:flutter/material.dart';
import 'package:kotak_infak/provider/auth_provider.dart';
import 'package:kotak_infak/provider/bluetooth_provider.dart';
import 'package:kotak_infak/provider/theme_provider.dart';
import 'package:kotak_infak/utils/app_constants.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  static const String route = 'Settings';

  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  List themes = Constants.themes;
  SharedPreferences? prefs;
  ThemeNotifier? themeNotifier;
  BluetoothProvider? bluetoothProvider;

  @override
  Widget build(BuildContext context) {
    themeNotifier = Provider.of<ThemeNotifier>(context);
    bluetoothProvider = Provider.of<BluetoothProvider>(context);
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: authProvider.user.level == 'Petugas'
          ? AppBar(
              title: const Text('Settings'),
            )
          : null,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dark Theme',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: themeNotifier!.getThemeMode() == ThemeMode.dark
                      ? true
                      : false,
                  onChanged: (value) {
                    themeNotifier!.setThemeMode(
                        value == true ? ThemeMode.dark : ThemeMode.light);
                  },
                )
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Bluetooth Print',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                bluetoothProvider!.items.isNotEmpty
                    ? Expanded(
                        flex: 1,
                        // width: 150,
                        child: DropdownButton(
                            elevation: 2,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            isExpanded: true,
                            isDense: true,
                            itemHeight: null,
                            underline: const SizedBox.shrink(),
                            value:
                                bluetoothProvider!.currentBluetooth.macAdress,
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Pilih Printer'),
                              ),
                              ...List.generate(bluetoothProvider!.items.length,
                                  (index) {
                                final BluetoothInfo bluetooth =
                                    bluetoothProvider!.items[index];
                                return DropdownMenuItem(
                                  value: bluetooth.macAdress,
                                  child: Text(bluetooth.name),
                                );
                              })
                            ],
                            onChanged: (value) {
                              if (value == '') {
                                bluetoothProvider!.disconnect();
                              } else {
                                bluetoothProvider!.currentBluetooth.macAdress ==
                                        value
                                    ? bluetoothProvider!.disconnect()
                                    : bluetoothProvider!.connect(value!);
                              }
                            }),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          bluetoothProvider!.getBluetooths();
                        },
                        child: Row(
                          children: [
                            Visibility(
                              visible: bluetoothProvider!.progress,
                              child: const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 1,
                                    backgroundColor: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(bluetoothProvider!.progress
                                ? bluetoothProvider!.msjprogress
                                : "Search"),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          const Divider()
        ],
      ),
    );
  }
}
