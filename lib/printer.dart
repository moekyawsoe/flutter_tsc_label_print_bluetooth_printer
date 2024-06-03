import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

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

List<LineText> parseData(Uint8List generatedData) {
  List<LineText> list = [];
  ByteData data = ByteData.view(generatedData.buffer);
  List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  String base64Image = base64Encode(imageBytes);
  // list.add(LineText(type: LineText.TYPE_TEXT, x:10, y:40, content: 'Continue Print'));
  list.add(LineText(type: LineText.TYPE_IMAGE, x:20, y:20, content: base64Image,));
  // list.add(LineText(type: LineText.TYPE_QRCODE, x:10, y:70, content: 'qrcode i\n'));
  // list.add(LineText(type: LineText.TYPE_BARCODE, x:10, y:190, content: 'qrcode i\n'));
  return list;
}