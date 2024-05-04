import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapView extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapView({Key? key, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final WebViewController controller;
   void initState() {
    super.initState();

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) 
            {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}'));
    // #enddocregion webview_controller
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
      ),
      body: WebViewWidget(controller: controller),
      // WebView(
      //   initialUrl:
      //       'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}',
      //   javascriptMode: JavascriptMode.unrestricted,
      // ),
    );
  }
}
