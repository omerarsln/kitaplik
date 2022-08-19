// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _scanBarcode = 'Unknown';

  Future fetchBookData(isbnNumber) async {
    String url = "https://openlibrary.org/isbn/$isbnNumber.json";

    final response = await http.get(Uri.parse(url));

    var responseData = jsonDecode(response.body);
    if (responseData["error"] != null) {
      return "error";
    } else {
      print(responseData);
      return "data";
    }
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      showAlertDialog();
    });
  }

  showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
            future: fetchBookData(_scanBarcode),
            builder: (context, snapshot) {
              List<Widget> actions = [
                const Text(""),
                const Text(""),
              ];
              Widget title = const Text("");
              Widget content = const Text("");
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = const SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                title = const Text("Title");
                content = const Text("Content");
                actions = [
                  TextButton(
                    child: const Text("İptal"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text("Ekle"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ];
              }
              return AlertDialog(
                actions: actions,
                title: title,
                content: content,
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitaplık"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {scanQR()},
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Text(_scanBarcode),
        ],
      ),
    );
  }
}



/*               actions:      */