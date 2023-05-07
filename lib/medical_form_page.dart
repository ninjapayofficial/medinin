import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class MedicalForm {
  final String title;
  final String fileName;

  MedicalForm({required this.title, required this.fileName});
}

class MedicalFormsPage extends StatefulWidget {
  @override
  _MedicalFormsPageState createState() => _MedicalFormsPageState();
}

class _MedicalFormsPageState extends State<MedicalFormsPage> {
  late List<String> _popularForms;
  late List<String> _allForms;
  late List<String> _medicalForms = [];
  late List<String> _filteredMedicalForms = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedicalForms();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String searchText = _searchController.text;
    if (searchText.isEmpty) {
      _filteredMedicalForms = List.from(_medicalForms);
    } else {
      _filteredMedicalForms = _medicalForms
          .where(
              (form) => form.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  Future<void> _loadMedicalForms() async {
    _popularForms = await _getFormsInDirectory('lib/forms/popular');
    _allForms = await _getFormsInDirectory('lib/forms/all');

    print('Popular forms: $_popularForms');
    print('All forms: $_allForms');

    _popularForms = _convertFilenamesToTitles(_popularForms);
    _allForms = _convertFilenamesToTitles(_allForms);

    _medicalForms = [..._popularForms, ..._allForms];
    _filteredMedicalForms = List.from(_medicalForms); // Add this line

    print('Medical forms: $_medicalForms');

    setState(() {});
  }

  Future<List<String>> _getFormsInDirectory(String path) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final pdfFiles = manifestMap.keys
        .where((String key) => key.startsWith(path) && key.endsWith('.pdf'))
        .toList();

    print('PDF files found: $pdfFiles');

    return pdfFiles.map((file) => file.split('/').last).toList();
  }

  List<String> _convertFilenamesToTitles(List<String> filenames) {
    return filenames.map((filename) => filename.replaceAll('_', ' ')).toList();
  }

  Future<void> _showPdfOptions(String title) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Options'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('View'),
            onPressed: () {
              _openPDF(title);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Share'),
            onPressed: () async {
              await _sharePDF(title);
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _openPDF(String title) async {
    String pdfFileName = title.replaceAll(' ', '_');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$pdfFileName');
    final data = await rootBundle.load('lib/forms/all/$pdfFileName');
    final bytes = data.buffer.asUint8List();
    await file.writeAsBytes(bytes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: PDFView(
            filePath: file.path,
          ),
        ),
      ),
    );
  }

  Future<void> _sharePDF(String title) async {
    String pdfFileName = title.replaceAll(' ', '_');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$pdfFileName');
    final data = await rootBundle.load('lib/forms/all/$pdfFileName');
    final bytes = data.buffer.asUint8List();
    await file.writeAsBytes(bytes);

    await Share.shareFiles([file.path], mimeTypes: ['application/pdf']);
    print('Sharing PDF file: ${file.path}');
    await Share.shareFiles([file.path], mimeTypes: ['application/pdf']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Forms'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search medical forms',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMedicalForms.length,
              itemBuilder: (context, index) {
                final title = _filteredMedicalForms[index];
                return ListTile(
                  title: Text(title),
                  onTap: () {
                    _showPdfOptions(title);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
