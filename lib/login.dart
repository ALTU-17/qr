import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:qr/HistoryTab.dart';
import 'package:qr/demo.dart';
import 'package:qr/qr_code_scanner.dart'; // Update the import path accordingly
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';

class LogUrls {

  final String reg_id;
  final String user_id;
  final String academic_yr;
  final String role_id;
  final String name;

  LogUrls({required this.reg_id, required this.user_id, required this.academic_yr, required this.role_id, required this.name});


  factory LogUrls.fromJson(Map<String, dynamic> json) {
    return LogUrls(
        reg_id: json['reg_id'],
        user_id: json['user_id'],
        academic_yr: json['academic_yr'],
        role_id: json['role_id'],
        name: json['name']
    );
  }

  // Method to serialize SchoolInfo object into JSON
  Map<String, dynamic> toJson() {
    return {
      'reg_id': reg_id,
      'name': name,
      'user_id': user_id,
      'academic_yr': academic_yr,
      'role_id': role_id
    };
  }

}

class Login extends StatefulWidget {
  final String emailstr;

  Login(this.emailstr);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();
  String shortName="";
  bool shouldShowText = false; // Set this based on your condition
  bool shouldShowText2 = false; // Set this based on your condition

  String Acdstr="";


  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: widget.emailstr);
    // checkLoginStatus(); // Check login status when the login screen is initialized
  }

  void log(String ema, String pass) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Retrieving a string value
      String? school_info = prefs.getString('school_info');

      Map<String, dynamic> parsedData = json.decode(school_info!);

      // Access individual values from the parsed data
      String schoolId = parsedData['school_id'];
      String name = parsedData['name'];
       shortName = parsedData['short_name'];
      String url = parsedData['url'];
      String teacherApkUrl = parsedData['teacherapk_url'];
      String projectUrl = parsedData['project_url'];
      String defaultPassword = parsedData['default_password'];

      print('URL: $teacherApkUrl');

      http.Response response = await http.post(
        Uri.parse(teacherApkUrl + "LoginApi/login"),
        body: {'user_id': ema, 'password': pass},
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Success');



        if(response.body.contains('"error":true')){
          setState(() {
            shouldShowText = true;
          });

        } else{

          setState(() {
            shouldShowText = false;
          });

          // Parse the API response into SchoolInfo object
          LogUrls logUrls = LogUrls.fromJson(jsonDecode(response.body));

          // Convert SchoolInfo object to JSON
          String logDetJson = jsonEncode(logUrls.toJson());
          Map<String, dynamic> logUrls11 = jsonDecode(logDetJson);

          // Extract the academic_yr field
          String academicYr = logUrls11['academic_yr'];
          print('logDetJson===>  $academicYr');

          // Store JSON string in shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('logUrls', logDetJson);

          // Store login status in SharedPreferences
          storeLoginStatus(true);
          // Navigate to QRScannerPage after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HistoryTab()),
          );


        }


      } else {

        setState(() {
          shouldShowText = true;
        });

        print('Failed');
        // Handle failed login
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // Store login status in SharedPreferences
  Future<void> storeLoginStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // Check login status
  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // If user is already logged in, navigate to QRScannerPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QRScannerPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/img.png', // Replace with your background image
              fit: BoxFit.cover,
            ),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    Image.asset(
                      'assets/logo.png', // Replace with your logo image
                      width: 200,
                      height: 140,
                    ),
                    SizedBox(height: 40),
                    Text(
                      '$shortName Smart QR code scanner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 50),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 140),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        enabled: false,
                        controller: email,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.person_outline),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.lock_person_outlined),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 5),
                    Visibility(
                      visible: shouldShowText, // Set this boolean based on your condition
                      child: Text(
                        'Login credentials are wrong. Please try again!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: shouldShowText2, // Set this boolean based on your condition
                      child: Text(
                        'Please Enter Password!!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                
                    SizedBox(height: 10),
                    Container(
                      height: 40,
                      width: 180,
                      decoration: BoxDecoration(
                          color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () {

                          if(password.text.toString().isEmpty){
                            setState(() {
                              shouldShowText2 = true;
                            });

                            Fluttertoast.showToast(
                              msg: 'Please Enter Password!!',
                              backgroundColor: Colors.black45,
                              textColor: Colors.white,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );

                          } else {
                            setState(() {
                              shouldShowText2 = false;
                            });
                            log(email.text.toString(), password.text.toString());
                          }
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                
                    SizedBox(height: 50),
                    Text(
                      'aceventuraservices@gmail.com',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}