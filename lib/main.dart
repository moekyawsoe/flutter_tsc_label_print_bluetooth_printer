import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:label_print_bluetooth_myanmar/printer.dart';
import 'package:label_print_bluetooth_myanmar/text_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLPM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Label Print Myanmar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // bluetooth init
  BluetoothPrint bluetoothPrint = getPrinter();
  bool _connected = false;
  BluetoothDevice? _device;

  String status = "";

  var _img;

  Future<void> initBluetooth() async {
    _connected = await getConnection();
    if(_connected){
      status = "CONNECTED";
    }else{
      status = "DISCONNECTED";
    }
  }

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  @override
  Widget build(BuildContext context) {
    var previewWidget = _img != null ? Image.memory(_img, width: 500, fit: BoxFit.contain, height: 300) : Text(_connected ? 'Preview' : '');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showConnectionStatus(context),
          printerList(context),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: previewWidget,
          ),
          showPrintButton(context)
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data == true) {
            return FloatingActionButton(
              onPressed: () => bluetoothPrint.stopScan(),
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search_outlined),
                onPressed: () => bluetoothPrint.startScan(
                    timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }

  Widget printerList(BuildContext context){
    return _connected ? const Padding(
      padding: EdgeInsets.all(8.0),
      child: null,
    ) :  StreamBuilder<List<BluetoothDevice>>(
      stream: bluetoothPrint.scanResults,
      initialData: const [],
      builder: (c, snapshot) => Column(
        children: snapshot.data!
            .map((d) => ListTile(
          title: Text(d.name ?? ''),
          subtitle: Text(d.address ?? ''),
          onTap: () {},
          trailing:
          _device != null && _device!.address == d.address
              ? OutlinedButton(
              onPressed: () async {
                if(_connected){
                  await bluetoothPrint.disconnect();
                  setState(() {
                    status = "DISCONNECTED";
                    _device = null;
                    _connected = false;
                  });
                }
              },
              child: const Text('Disconnect'))
              : OutlinedButton(
              onPressed: () async {
                await connectDevice(d);
                setState(() {
                  _device = d;
                  status = "CONNECTED";
                  _connected = true;
                });
              },
              child: const Text('Connect')),
        ))
            .toList(),
      ),
    );
  }

  Widget showConnectionStatus(BuildContext context){
    String? deviceName = _device != null ? _device?.name : "";
    return _connected ? Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("$status $deviceName"),
    ) : Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(status),
    );
  }

  Widget showPrintButton(BuildContext context){
    return _connected ? Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
          onPressed: () async {
            await printBill();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 25.0),
            child: Text('Print'),
          )),
    ) : const Padding(
      padding: EdgeInsets.all(8.0),
      child: null,
    );
  }

  printBill() async {
    List<TextParam> textParams = [
      TextParam(
        text: "ဝယ်သူနာမည် : မောင်မောင်",
        offset: const Offset(0, 10),
        fontSize: 28,
        fontWeight: FontWeight.w700,
        textDirection: TextDirection.rtl,
      ),
      TextParam(
        text: "နေရပ်လိပ်စာ : ပြင်ဦးလွင်",
        offset: const Offset(0, 80), // Adjust the offset as needed
      ),
      TextParam(
        text: "အရေအတွက် : အလုံး ၅၀",
        offset: const Offset(0, 120), // Adjust the offset as needed
      ),
    ];
    Uint8List data = await generateData(textParams);

    List<LineText> buffer = parseData(data);

    Map<String, dynamic> config = {};
    config['width'] = 72;
    config['height'] = 80;
    config['gap'] = 2;
    await bluetoothPrint.printLabel(config, buffer);

    //optional preview
    setState(() {
      _img = data;
    });
  }
}
