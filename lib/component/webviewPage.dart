// // import 'dart:async';
// // import 'dart:convert';

// import 'dart:async';

// import 'package:Investrend/utils/investrend_theme.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewPage extends StatefulWidget {
//   @override
//   _WebViewPageState createState() => _WebViewPageState();
// }

// class _WebViewPageState extends State<WebViewPage> {
//   // final Completer<WebViewController> _controller =
//   //     Completer<WebViewController>();
//   // WebViewController _con;
//   // final flutterWebviewPlugin = new FlutterWebviewPlugin();

//   @override
//   dispose() {
//     // flutterWebviewPlugin.dispose();
//     super.dispose();
//   }

//   String setHTML() {
//     return ('''<!DOCTYPE html>
//     <html>
//       <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
//       <body style='"margin: 0; padding: 0;'>
//         <div>
//           <h2 style="font-style:italic;">Test String</h2>

//           <p>Test HTML String, buat di load di WebView <strong>flutter</strong></p>
//         </div>
//       </body>
//     </html>''');
//   }

//   _printz() => print("Hello");

//   // _loadHTML() async {
//   //   _con.loadUrl(Uri.dataFromString(
//   //     setHTML(),
//   //     mimeType: 'text/html',
//   //     encoding: Encoding.getByName('utf-8'),
//   //   ).toString());
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: WillPopScope(
//         onWillPop: () async {
//           final completer = Completer<bool>();
//           flutterWebviewPlugin.close().whenComplete(() {
//             Navigator.of(context).pop();
//             completer.complete(true); // Indicate that it's safe to pop
//           });
//           return completer.future;

//           // return flutterWebviewPlugin.close().whenComplete(
//           //       () => Navigator.of(context).pop(),
//           //     );
//         },
//         child: WebviewScaffold(
//           url: new Uri.dataFromString(
//             setHTML(),
//             mimeType: 'text/html',
//           ).toString(),
//           appBar: PreferredSize(
//             preferredSize: Size.fromHeight(40.0),
//             child: AppBar(
//               title: Text("Webview HTML"),
//               backgroundColor: Colors.white,
//               leading: IconButton(
//                 icon: Icon(Icons.arrow_back),
//                 onPressed: () {
//                   debugPrint(
//                       "RIZKY PEBRIAN ========================== ${InvestrendTheme.datafeedHttp.baseUrlLocalhost}/TV/index.html");
//                   flutterWebviewPlugin.close().whenComplete(
//                         () => Navigator.of(context).pop(),
//                       );
//                 },
//               ),
//             ),
//           ),
//           initialChild: Container(
//             color: Colors.blueGrey,
//             child: const Center(
//               child: Text("Please wait a moment"),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   /*
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('WebView HTML String'),
//       ),
//       body: Builder(builder: (BuildContext context) {
//         return WebView(
//           initialUrl: 'https://flutter.dev',
//           javascriptMode: JavascriptMode.unrestricted,
//           onWebViewCreated: (WebViewController webViewController) {
//             // _controller.complete(webViewController);
//             _con = webViewController;
//             _loadHTML();
//           },
//           onProgress: (int progress) {
//             print("WebView is loading (progress : $progress%)");
//           },
//           navigationDelegate: (NavigationRequest request) {
//             if (request.url.startsWith('https://www.youtube.com/')) {
//               print('blocking navigation to $request}');
//               return NavigationDecision.prevent;
//             }
//             print('allowing navigation to $request');
//             return NavigationDecision.navigate;
//           },
//           onPageStarted: (String url) {
//             print('Page started loading: $url');
//           },
//           onPageFinished: (String url) {
//             print('Page finished loading: $url');
//           },
//           gestureNavigationEnabled: true,
//         );
//       }),
//     );
//   }
//   */
// }
