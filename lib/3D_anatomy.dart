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

  final Map<String, String> models = {
    'Male Up': 'http://anatomymobile.medinin.com/model-mobile/male-torso-up',
    'Male Torso': 'http://anatomymobile.medinin.com/model-mobile/male-torso',
    'Head': 'http://anatomymobile.medinin.com/model-mobile/head',
    'Urinary': 'http://anatomymobile.medinin.com/model-mobile/urinary',
    'Female Urinary':
        'http://anatomymobile.medinin.com/model-mobile/female-urinary',
    'Skull': 'http://anatomymobile.medinin.com/model-mobile/skull',
    'Mouth': 'http://anatomymobile.medinin.com/model-mobile/mouth',
    'Brain': 'http://anatomymobile.medinin.com/model-mobile/brain',
    'Heart': 'http://anatomymobile.medinin.com/model-mobile/heart',
    'Digestive': 'http://anatomymobile.medinin.com/model-mobile/digestive',
    'Breast': 'http://anatomymobile.medinin.com/model-mobile/breast',
    'Hand': 'http://anatomymobile.medinin.com/model-mobile/hand',
    'Leg': 'http://anatomymobile.medinin.com/model-mobile/leg',
    'Nose': 'http://anatomymobile.medinin.com/model-mobile/nose',
    'Eye': 'http://anatomymobile.medinin.com/model-mobile/eye',
    'Teeth': 'http://anatomymobile.medinin.com/model-mobile/teeth',
    'Kidney': 'http://anatomymobile.medinin.com/model-mobile/kidney',
    'Spinal': 'http://anatomymobile.medinin.com/model-mobile/spinal',
    'Pelvis': 'http://anatomymobile.medinin.com/model-mobile/pelvis',
    'Lungs': 'http://anatomymobile.medinin.com/model-mobile/lungs',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Anatomy Model Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => _showModelOptions(),
          ),
        ],
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

  void _showModelOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select a model'),
          children: models.entries.map((entry) {
            return SimpleDialogOption(
              child: Text(entry.key),
              onPressed: () {
                Navigator.pop(context);
                _webViewController.loadUrl(entry.value);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
