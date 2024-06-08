import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/services.dart';

BluetoothPrint getPrinter() {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  return bluetoothPrint;
}

Future<bool> getConnection() async {
  bool status = false;
  BluetoothPrint bluetoothPrint = getPrinter();
  bool isConnected = await bluetoothPrint.isConnected ?? false;
  bluetoothPrint.state.listen((state) {
    switch (state) {
      case BluetoothPrint.CONNECTED:
        status = true;
        break;
      case BluetoothPrint.DISCONNECTED:
        status = false;
        break;
      default:
        break;
    }
  });

  if (isConnected) {
    status = true;
  }
  return status;
}

Future<void> connectDevice(BluetoothDevice? device) async {
  BluetoothPrint bluetoothPrint = getPrinter();
  await bluetoothPrint.connect(device!);
}

Future<List<LineText>> parseData(Uint8List generatedData) async {
  List<LineText> list = [];
  ByteData data = ByteData.view(generatedData.buffer);
  List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  String base64Image = base64Encode(imageBytes);

  list.add(LineText(type: LineText.TYPE_IMAGE, width: 575, x:0, y:10, content: base64Image,));
  list.add(LineText(type: LineText.TYPE_BARCODE, content: '123456789', size: 10, x:160, y:20, align: LineText.ALIGN_CENTER, linefeed: 1));
  return list;
}