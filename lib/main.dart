import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:qr/HistoryTab.dart';
import 'package:qr/api.dart';
import 'package:qr/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'QR_Code_Scanner.dart';
import 'demo.dart';

class SchoolInfo {
  final String schoolId;
  final String name;
  final String shortName;
  final String url;
  final String teacherApkUrl;
  final String projectUrl;
  final String defaultPassword;

  SchoolInfo({
    required this.schoolId,
    required this.name,
    required this.shortName,
    required this.url,
    required this.teacherApkUrl,
    required this.projectUrl,
    required this.defaultPassword,
  });

  // Method to deserialize JSON into SchoolInfo object
  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      schoolId: json['school_id'],
      name: json['name'],
      shortName: json['short_name'],
      url: json['url'],
      teacherApkUrl: json['teacherapk_url'],
      projectUrl: json['project_url'],
      defaultPassword: json['default_password'],
    );
  }

  // Method to serialize SchoolInfo object into JSON
  Map<String, dynamic> toJson() {
    return {
      'school_id': schoolId,
      'name': name,
      'short_name': shortName,
      'url': url,
      'teacherapk_url': teacherApkUrl,
      'project_url': projectUrl,
      'default_password': defaultPassword,
    };
  }
}

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginDemo(),
    );
  }
}



class LoginDemo extends StatefulWidget {

  @override
  _LoginDemoState createState() => _LoginDemoState();

}

class _LoginDemoState extends State<LoginDemo> {

  @override
  void initState() {
    super.initState();
    // email = TextEditingController(text: widget.emailstr);
    checkLoginStatus(); // Check login status when the login screen is initialized
  }

// Define a class to represent the user's school information

  TextEditingController email = TextEditingController();

  bool shouldShowText = false; // Set this based on your condition
  bool shouldShowText2 = false; // Set this based on your condition


// Modify your login function to store school info in shared preferences
  void loginfun(String emailstr) async {
    try {
      Response response = await post(
        Uri.parse(ROOT),
        body: {'user_id': emailstr},
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Success');

        if(response.body.length < 30){


          Fluttertoast.showToast(
            msg: 'Invalid User ID!!',
            backgroundColor: Colors.black45,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );

        } else {

          setState(() {
            shouldShowText = false;
          });

          // Parse the API response into SchoolInfo object
          SchoolInfo schoolInfo = SchoolInfo.fromJson(jsonDecode(response.body));

          // Convert SchoolInfo object to JSON
          String schoolInfoJson = jsonEncode(schoolInfo.toJson());
          print('scool $schoolInfoJson');


          // Store JSON string in shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('school_info', schoolInfoJson);



          // Navigate to the login screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Login(emailstr)),
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

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // If user is already logged in, navigate to QRScannerPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HistoryTab()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // checkLoginStatus(); // Check login status when the login screen is initialized

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
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
                    SizedBox(height: 60),
                    Image.asset(
                      'assets/logo.png', // Replace with your logo image
                      width: 200,
                      height: 140,
                    ),
                    SizedBox(height: 60),
                    Text(
                      'Smart QR code scanner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 60),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 180),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: email,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.person_outline),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 5),
                    Visibility(
                      visible: shouldShowText, // Set this boolean based on your condition
                      child: Text(
                        'Invalid UserId!!!',
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
                        'Please Enter User Name!!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),


                    SizedBox(height: 40),
                    Container(
                      height: 40,
                      width: 180,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () {
                          if(email.text.toString().isEmpty){

                            setState(() {
                              shouldShowText2 = true;
                            });

                            Fluttertoast.showToast(
                              msg: 'Please Enter User Name!!',
                              backgroundColor: Colors.black45,
                              textColor: Colors.white,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );
                
                          } else {
                            setState(() {
                              shouldShowText2 = false;
                            });
                            loginfun(email.text.toString());
                
                          }
                
                        },
                        child: Text(
                          'Next',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    // SizedBox(height: 50),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     Container(
                    //       width: 60,
                    //       height: 60,
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: AssetImage('assets/chemistry.png'),
                    //         ),
                    //       ),
                    //     ),
                    //     Container(
                    //       width: 60,
                    //       height: 60,
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: AssetImage('assets/nextimg.png'),
                    //         ),
                    //       ),
                    //     ),
                    //     Container(
                    //       width: 60,
                    //       height: 60,
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: AssetImage('assets/cup.png'),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Text(
                        'aceventuraservices@gmail.com',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
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
