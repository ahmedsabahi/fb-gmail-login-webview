import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue/gen/flutterblue.pbjson.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_blue/flutter_blue.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({Key key, @required this.url}) : super(key: key);

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  int _counter = 0;
  Uint8List _imageFile;
  // TestPrint testPrint;

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, imageFile) async {
    final image = pw.MemoryImage(imageFile);
    final pdf = pw.Document();
    print('-------------------------$image');
    print('-------------------------$imageFile');

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
        child: pw.Image(image),
      ); // Center
    }));

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.url);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('welcome '),
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
                  _incrementCounter();
                  _imageFile = null;
                  screenshotController.capture().then((image) async {
                    print('Successful Screenshot => $image');

                    PdfPreview(
                      build: (format) => _generatePdf(format, image),
                    );
                  }).catchError((onError) {
                    print('-----Error------$onError');
                  });
                },
                child: Icon(
                  Icons.local_printshop_rounded,
                  size: 26.0,
                ),
              ),
            ),
          ],
        ),
        body: Screenshot(
          controller: screenshotController,
          child: WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
