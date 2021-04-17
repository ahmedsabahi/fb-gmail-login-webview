import 'dart:io';
import 'dart:typed_data';
import 'package:easacc_task/widgets/testprint.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  final String url;

  WebViewExample({Key key, @required this.url}) : super(key: key);

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  int _counter = 0;
  Uint8List _imageFile;
  TestPrint testPrint;

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  _afterLayout(_) {
    testPrint = TestPrint();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
              child: GestureDetector(
                onTap: () {
                  _incrementCounter();
                  _imageFile = null;
                  screenshotController.capture().then((Uint8List image) async {
                    _imageFile = image;
                    print('Successful Screenshot => $_imageFile');
                    testPrint.sample(_imageFile);
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
