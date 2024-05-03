import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HistoryTab.dart';
import 'Scanner.dart';
import 'main.dart';

class ProfileTab extends StatelessWidget {
  String academic_yr = "";

  final rememberMeProvider = StateNotifierProvider<RememberMeNotifier, bool>((ref) {
    return RememberMeNotifier(); // Your custom notifier class
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Pop until reaching the HistoryTab route
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HistoryTab()),
        );
        return false;
      },
      child: ProviderScope(
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                'assets/img.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),


              // Main content of the screen
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // User details
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Column(
                            children: [
                              Text(
                                'User ID: ${snapshot.data?['user_id'] ?? ''}',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'User Name: ${snapshot.data?['name'] ?? ''}',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    // SizedBox(height: 570),



                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0,bottom: 20,left: 10),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => QRScanPage()),
              );
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.qr_code),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 10,
      backgroundColor: Colors.pink,
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              Fluttertoast.showToast(
                msg: 'Developed by ALTU',
                backgroundColor: Colors.black45,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => QRScanPage()),
              );
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
                  '$academic_yr', // Display academic year here
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.history_edu),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HistoryTab()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? logUrls = prefs.getString('logUrls');
    if (logUrls != null) {
      Map<String, dynamic> logUrls_ParsedData = json.decode(logUrls);
      academic_yr = logUrls_ParsedData['academic_yr'];
      return logUrls_ParsedData;
    } else {
      return {};
    }
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn'); // Clear login status
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginDemo()),
    );
  }
}
class RememberMeNotifier extends StateNotifier<bool> {
  RememberMeNotifier() : super(false);

  void toggleRememberMe() {
    state = !state;
  }
}