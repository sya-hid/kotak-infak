import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothProvider extends ChangeNotifier {
  bool _connected = false;
  bool get connected => _connected;

  final bool _status = false;
  bool get status => _status;
  bool _progress = false;
  bool get progress => _progress;
  String _msjprogress = "";
  String get msjprogress => _msjprogress;

  String _msj = '';
  String get msj => _msj;
  String _info = "";
  String get info => _info;

  BluetoothInfo get currentBluetooth => _currentBluetooth!;
  BluetoothInfo? _currentBluetooth = BluetoothInfo(name: '', macAdress: '');

  checkStatus() async {
    final bool result = await PrintBluetoothThermal.connectionStatus;
    _connected = result;
    PrintBluetoothThermal.pairedBluetooths;
    notifyListeners();
  }

  List<BluetoothInfo> _items = [];
  List<BluetoothInfo> get items => _items;

  Future<void> getBluetooths() async {
    _progress = true;
    _msjprogress = "Wait";
    // _items = [];
    notifyListeners();
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    _progress = false;

    if (listResult.isEmpty) {
      _msj = "There are no bluetoohs linked, go to settings and link the loger";
    } else {
      _msj = "Touch an item in the list to connect";
    }
    _items = listResult;
    notifyListeners();
  }

  Future<void> connect(String mac) async {
    _progress = true;
    _msjprogress = "Connecting...";
    _connected = false;
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    if (result) {
      _connected = true;
    }
    _progress = false;
    // _currentBluetooth = bluetoothInfo;
    _currentBluetooth = BluetoothInfo(name: 'name', macAdress: mac);
    notifyListeners();
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    _connected = status;
    // _connected = false;
    _currentBluetooth = BluetoothInfo(name: '', macAdress: '');
    notifyListeners();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    if (result) {
      _msj = "Bluetooth enabled, please search and connect";
    } else {
      _msj = "Bluetooth not enabled";
    }

    // setState(() {
    _info = "$platformVersion ($porcentbatery% battery)";
    // });
    notifyListeners();
  }
}
