import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:image/image.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'dart:io' show Platform;

class Print extends StatefulWidget {
  final String data;

  Print(this.data);

  @override
  _PrintState createState() => _PrintState();
}

class _PrintState extends State<Print> {
  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String _devicesMsg;
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  @override
  void initState() {
    if (Platform.isIOS) {
      initPrinter();
    } else {
      bluetoothManager.state.listen((val) {
        print("state = $val");
        if (!mounted) return;
        if (val == 12) {
          print('on');
          initPrinter();
        } else if (val == 10) {
          print('off');
          setState(() {
            _devicesMsg = 'Please enable bluetooth to print';
          });
        }
        print('state is $val');
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Printer page"), backgroundColor: Colors.black45),
      body: _devices.isNotEmpty
          ? ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, position) => ListTile(
                leading: Icon(Icons.print),
                title: Text(_devices[position].name),
                subtitle: Text(_devices[position].address),
                onTap: () {
                  // _printerManager.selectPrinter(_devices[position]);
                  _startPrint(_devices[position]);
                },
              ),
            )
          : Center(
              child: Text(
                _devicesMsg ?? 'Ops something went wrong!',
                style: TextStyle(fontSize: 24),
              ),
            ),
    );
  }

  void initPrinter() {
    print('init printer');
    _printerManager.startScan(Duration(seconds: 4));
    _printerManager.scanResults.listen((event) {
      if (!mounted) return;
      setState(() => _devices = event);

      if (_devices.isEmpty) setState(() => _devicesMsg = 'No devices');
    });
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
    final myTicket = await _ticket(PaperSize.mm58);
    final result = await _printerManager.printTicket(myTicket);

    print(result);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(result.msg),
      ),
    );
  }

  Future<Ticket> _ticket(PaperSize paper) async {
    final ticket = Ticket(paper);

    // // Image assets
    // final ByteData data = await rootBundle.load('assets/easacc_Logo.png');
    // final Uint8List bytes = data.buffer.asUint8List();
    // final Image image = decodeImage(bytes);
    // ticket.image(image);
    //
    // // Image network
    // final ByteData dataa =
    //     await NetworkAssetBundle(Uri.parse('YOUR URL')).load("");
    // final Uint8List bytess = dataa.buffer.asUint8List();
    // final Image imagee = decodeImage(bytess);
    // ticket.image(imagee);

    ticket.text(widget.data);

    // int total = 0;
    ticket.text(
      'EASACC',
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2),
      linesAfter: 1,
    );

    ticket.row([
      PosColumn(text: widget.data, width: 6),
    ]);

    // ticket.text('Thank You EASACC',
    //     styles: PosStyles(align: PosAlign.center, bold: true));
    //
    // //test printer
    // for (var i = 0; i < widget.data.length; i++) {
    //   total += widget.data[i]['total_price'];
    //   ticket.text(widget.data[i]['title']);
    //   ticket.row([
    //     PosColumn(
    //         text: '${widget.data[i]['price']} x ${widget.data[i]['qty']}',
    //         width: 6),
    //     PosColumn(text: 'Rp ${widget.data[i]['total_price']}', width: 6),
    //   ]);
    // }
    ticket.cut();
    return ticket;
  }

  @override
  void dispose() {
    _printerManager.stopScan();
    super.dispose();
  }
}
