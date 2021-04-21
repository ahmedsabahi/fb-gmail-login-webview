import 'dart:io';
import 'package:easacc_task/screens/printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({Key key, @required this.url}) : super(key: key);

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  // Reference to webview controller
  WebViewController _controller;
  String _html;

  // // Example Data to test printer
  // final List<Map<String, dynamic>> data = [
  //   {
  //     'title': 'item 1',
  //     'price': 100,
  //     'qty': 2,
  //     'total_price': 200,
  //   },
  //   {
  //     'title': 'item 2',
  //     'price': 2000,
  //     'qty': 2,
  //     'total_price': 4000,
  //   },
  // ];

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
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Print(_html),
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
      body: Container(
          child: WebView(
        initialUrl: widget.url,
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        javascriptMode: JavascriptMode.unrestricted,
        gestureNavigationEnabled: true,
        onPageFinished: (_) {
          readJS();
        },
      )),
    );
  }

  void readJS() async {
    String html = await _controller.evaluateJavascript(
        "window.document.getElementsByTagName('html')[0].innerText;");

    setState(() {
      _html = html;
    });
    print(html);
  }
}
