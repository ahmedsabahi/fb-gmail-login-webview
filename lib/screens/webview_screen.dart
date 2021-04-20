import 'dart:io';
import 'dart:typed_data';
import 'package:easacc_task/utils/printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter_blue/gen/flutterblue.pbjson.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'dart:ui' as ui;

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({Key key, @required this.url}) : super(key: key);

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  int _counter = 0;

  // Example Data to test printer
  final List<Map<String, dynamic>> data = [
    {
      'title': 'item 1',
      'price': 100,
      'qty': 2,
      'total_price': 200,
    },
    {
      'title': 'item 2',
      'price': 2000,
      'qty': 2,
      'total_price': 4000,
    },
  ];

  ScreenshotController screenshotController = ScreenshotController();
  GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.url}'),
        backgroundColor: Color(0xFF2C384A),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
              onPressed: () async {
                RenderRepaintBoundary renderRepaintBoundary =
                    _containerKey.currentContext.findRenderObject();
                ui.Image boxImage =
                    await renderRepaintBoundary.toImage(pixelRatio: 1);
                ByteData byteData =
                    await boxImage.toByteData(format: ui.ImageByteFormat.png);
                Uint8List uInt8List = byteData.buffer.asUint8List();

                print(uInt8List);

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Print(data, uInt8List),
                ));
              },
              child: Icon(
                Icons.local_printshop_rounded,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _containerKey,
        child: WebView(
          allowsInlineMediaPlayback: true,
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
