import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewNew extends StatefulWidget {
  @override
  _WebviewNewState createState() => _WebviewNewState();
}

class _WebviewNewState extends State<WebviewNew> {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('http://svc1.buanacapital.com/TV/'));

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.landscapeRight,
      // DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);
    // flutterWebviewPlugin.dispose();
    super.dispose();
  }

  // String setHTML() {
  //   return ('''<!DOCTYPE html>
  //   <html>
  //     <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
  //     <body style='"margin: 0; padding: 0;'>
  //       <div>
  //         <h2 style="font-style:italic;">Test String</h2>

  //         <p>Test HTML String, buat di load di WebView <strong>flutter</strong></p>
  //       </div>
  //     </body>
  //   </html>''');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webview Container'),
      ),
      // body: WebViewWidget(controller: controller),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
