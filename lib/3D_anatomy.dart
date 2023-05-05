import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Anatomy3DModelViewer extends StatefulWidget {
  final String modelUrl;

  const Anatomy3DModelViewer({Key? key, required this.modelUrl})
      : super(key: key);

  @override
  _Anatomy3DModelViewerState createState() => _Anatomy3DModelViewerState();
}

class _Anatomy3DModelViewerState extends State<Anatomy3DModelViewer> {
  double _value = 0.0;
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Anatomy Model Viewer'),
      ),
      body: Column(
        children: [
          Expanded(
            child: WebView(
              initialUrl: widget.modelUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Layer: ${(_value * 100).toInt()}'),
                Expanded(
                  child: Slider(
                    value: _value,
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                      _changeLayers(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeLayers(double value) {
    _webViewController.runJavascript('changeLayers(${(value * 100).toInt()})');
  }
}
