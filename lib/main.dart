import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/foundation.dart';
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
    var previewWidget = _img != null ? Image.memory(_img, width: 575, fit: BoxFit.contain, height: 500) : Text(_connected ? 'Preview' : '');
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
    String printData = """
    From    :   Mee Online Shop
                09123456789, 09123456789
    ------------------------------------
    To      :   မောင်မောင်ကျော်ကျော်မြင့် (မဟာမိုဘိုင်း)
                09123456789, 09123456789
                အမှတ် (၁၀), ကမ်းနားလမ်း
                ရန်ကုန်တိုင်းဒေသကြီး
    -------------------------------------
    22-Feb-2024   Weight    :           3
    North Dagon   Subtotal  :     150,000
                  Delivery  :       3,000
                  Overweight:       1,000
       PAID       Grand Total:    190,000
    -------------------------------------
    Remark  :
    
    
    
    """;
    List<TextParam> textParams = [
      TextParam(
        text: "From   :",
        offset: const Offset(5, 130),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "Mee Online Shop",
        offset: const Offset(155, 130),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "09123456789, 09123456789",
        offset: const Offset(155, 160),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "",
        offset: const Offset(0, 190),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "To   :",
        offset: const Offset(5, 220),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "မောင်မောင်ချစ်ချော (ပြုပြင်ရေးမိုဘိုင်း)",
        offset: const Offset(155, 210),
        fontWeight: FontWeight.w600,
      ),
      TextParam(
        text: "09123456789, 09123456789",
        offset: const Offset(155, 260),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "No 123, ငပိန်လမ်း, စလုံးမြို့နယ်",
        offset: const Offset(155, 290),
        fontWeight: FontWeight.w600,
      ),
      TextParam(
        text: "ရန်ကုန်တိုင်း",
        offset: const Offset(155, 330),
        fontWeight: FontWeight.w600,
      ),
      TextParam(
        text: "",
        offset: const Offset(180, 380),
      ),
      TextParam(
        text: "22-Feb-2024",
        offset: const Offset(5, 400),
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "Weight         :",
        offset: const Offset(180, 400),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: formatPrice(3),
        offset: const Offset(450, 400),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "North Dagon",
        offset: const Offset(5, 440),
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "Subtotal      :",
        offset: const Offset(180, 430),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: formatPrice(100000),
        offset: const Offset(450, 430),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "Delivery       :",
        offset: const Offset(180, 460),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: formatPrice(300),
        offset: const Offset(450, 460),
        fontWeight: FontWeight.w900,
        textDirection: TextDirection.rtl
      ),
      TextParam(
        text: "Overweight    :",
        offset: const Offset(180, 490),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: formatPrice(1000),
        offset: const Offset(450, 490),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "PAID",
        offset: const Offset(50, 530),
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "Grand Total   :",
        fontSize: 26,
        offset: const Offset(180, 530),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: formatPrice(190000),
        fontSize: 26,
        offset: const Offset(450, 530),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "",
        offset: const Offset(0, 570),
        fontWeight: FontWeight.w900,
      ),
      TextParam(
        text: "Remark    : ",
        offset: const Offset(5, 590),
        fontWeight: FontWeight.w900,
      ),
    ];
    Uint8List data = await generateData(textParams);

    List<LineText> buffer = parseData(data);

    Map<String, dynamic> config = {};
    config['width'] = 72;
    config['height'] = 80;
    config['gap'] = 2;
    try{
      await bluetoothPrint.printLabel(config, buffer);
    }catch(er){
      if (kDebugMode) {
        print(er);
      }
    }

    //optional preview
    setState(() {
      _img = data;
    });
  }
}
