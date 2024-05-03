import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'HistoryTab.dart';
import 'ProfileTab.dart';
import 'Scanner.dart';
import 'demo.dart';
import 'main.dart';

class QRScannerPage extends StatefulWidget {


  @override
  _QRScannerPageState createState() => _QRScannerPageState();

}

class _QRScannerPageState extends State<QRScannerPage> {
  int _currentIndex = 0;
  String academic_yr="";

  @override
  void initState() {
    super.initState();
    fetchVisitorData();
  }

  Future<void> fetchVisitorData() async {

    final prefs = await SharedPreferences.getInstance();
    String? logUrls = prefs.getString('logUrls');

    Map<String, dynamic> logUrls_Paresedata = json.decode(logUrls!);

    // Access individual values from the parsed data
     academic_yr = logUrls_Paresedata['academic_yr'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          elevation: 10,
          backgroundColor: Colors.pink, // Change color to match your design
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.qr_code_scanner),
                onPressed: () {
                  // Handle menu button press
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EvolvU Smart QR App',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "$academic_yr",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.person_pin_rounded),
                onPressed: () {

                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => ProfileTab()),
                  // );

                  // Handle notification button press
                },
              ),
            ],
          ),
        ),
      ),
      body: _getBodyWidget(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR Code Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _getBodyWidget() {
    switch (_currentIndex) {
      case 0:
        return QRScanPage();

      case 1:
        return HistoryTab();

      case 2:
        // return ProfileTab();
      default:
        return Container(); // Placeholder, add error handling if needed
    }
  }
}

// class HistoryTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text("History Tab Content"),
//     );
//   }
// }

class QRCodeScanTab extends StatefulWidget {
  @override
  _QRCodeScanTabState createState() => _QRCodeScanTabState();
}

class _QRCodeScanTabState extends State<QRCodeScanTab> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  String qrCodeResult = "Not Yet Scanned";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        Text(
          "Result: $qrCodeResult",
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrCodeResult = scanData.code!;
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
