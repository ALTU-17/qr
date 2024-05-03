import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:qr/HistoryTab.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'QR_Code_Scanner.dart';
import 'api.dart';
import 'main.dart';

class FatherCheckboxNotifier extends StateNotifier<bool> {
  FatherCheckboxNotifier() : super(false);

  void toggleFatherCheckbox() {
    state = !state;
  }
}

class MotherCheckboxNotifier extends StateNotifier<bool> {
  MotherCheckboxNotifier() : super(false);

  void toggleMotherCheckbox() {
    state = !state;
  }
}

class GuardianCheckboxNotifier extends StateNotifier<bool> {
  GuardianCheckboxNotifier() : super(false);

  void toggleGuardianCheckbox() {
    state = !state;
  }
}


class QRScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String qrCode = "";
  String p = "";
  List<Map<String, dynamic>> studentData = [];
  bool isChecked = false;
  bool isFatherSelected = false;
  bool isMotherSelected = false;
  bool isGuardianSelected = false;

  String vistiBY="";

  final fatherCheckboxProvider = StateNotifierProvider<FatherCheckboxNotifier, bool>((ref) {
    return FatherCheckboxNotifier(); // Your custom notifier class
  });

  final motherCheckboxProvider = StateNotifierProvider<MotherCheckboxNotifier, bool>((ref) {
    return MotherCheckboxNotifier(); // Your custom notifier class
  });

  final guardianCheckboxProvider = StateNotifierProvider<GuardianCheckboxNotifier, bool>((ref) {
    return GuardianCheckboxNotifier(); // Your custom notifier class
  });


  @override
  void initState() {
    super.initState();
    // Call the scanQRCode function when the widget initializes
    scanQRCode();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              // Image.asset(
              //   'assets/img.png', // Replace with your background image
              //   fit: BoxFit.cover,
              // ),

              SizedBox(height: 8),
              Text(
                '$qrCode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;

      if (qrCode == '-1') {
        // User pressed cancel, navigate to HistoryTab
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HistoryTab()),
        );
        return;
      }

      setState(() {
        this.qrCode = qrCode;
        print('Print : "Parent ID"+$qrCode');
        // Call your API here
        fetchStudentData(qrCode);
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  Future<void> fetchStudentData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? school_info = prefs.getString('school_info');

      Map<String, dynamic> parsedData = json.decode(school_info!);

      // Access individual values from the parsed data
      String schoolId = parsedData['school_id'];
      String name = parsedData['name'];
      String shortName = parsedData['short_name'];
      String url = parsedData['url'];
      String teacherApkUrl = parsedData['teacherapk_url'];
      String projectUrl = parsedData['project_url'];
      String defaultPassword = parsedData['default_password'];

      String? logUrls = prefs.getString('logUrls');

      Map<String, dynamic> logUrls_Paresedata = json.decode(logUrls!);

      // Access individual values from the parsed data
      String academic_yr = logUrls_Paresedata['academic_yr'];
      String e_name = logUrls_Paresedata['name'];
      String user_id = logUrls_Paresedata['user_id'];
      String role_id = logUrls_Paresedata['role_id'];

      print('URL: $teacherApkUrl');

      final response = await http.post(
        Uri.parse(teacherApkUrl +
            'AdminApi/get_student_parent_data_by_qrcode_parent_id'),
        body: json.encode({
          'short_name': shortName,
          'acd_yr': academic_yr,
          'parent_id': qrCode
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        final jsonResponse = json.decode(response.body);
        final studentList = jsonResponse['student_data'];
        setState(() {
          studentData = List<Map<String, dynamic>>.from(studentList);
          print('studentData $studentData');
        });

        // Show dialog with fetched data
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              'Parent and Student Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 10.9,
              child: SingleChildScrollView(
                child: ProviderScope(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display father's image and name
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isFatherSelected = !isFatherSelected;

                            // if(isFatherSelected = true){
                            //   vistiBY = "Father";
                            // }
                            //
                            // isMotherSelected = false;
                            // isGuardianSelected = false;

                            WidgetsFlutterBinding.ensureInitialized();
                            runApp(MyApp());

                            if (isFatherSelected == true) {
                              Fluttertoast.showToast(
                                msg: 'Father Selected',
                                backgroundColor: Colors.black45,
                                textColor: Colors.white,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                            }
                          });
                        },
                        child: Container(
                          color:
                              isFatherSelected ? Colors.blue : Colors.transparent,
                          child: Row(
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(right: 0.0),
                              //   child: Consumer(
                              //     builder: (context, ref, child) {
                              //       final isChecked = ref.watch(fatherCheckboxProvider);
                              //       return Checkbox(
                              //         value: isChecked,
                              //         onChanged: (newValue) {
                              //           ref.read(fatherCheckboxProvider.notifier).toggleFatherCheckbox();
                              //         },
                              //       );
                              //     },
                              //   ),
                              // ),

                              // Father's image
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Image.network(
                                  'https://sms.arnoldcentralschool.org/SACSv4test/uploads/parent_image/f_$qrCode.jpg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Handle error, for example, display a placeholder image
                                    return Image.asset(
                                      'assets/father.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              // Father's name
                              Flexible(
                                child: Text(
                                  'Father: ${studentData[0]['father_name']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isFatherSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),

                              ),


                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Display mother's image and name
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // isFatherSelected = false;
                            isMotherSelected = !isMotherSelected;
                            // isGuardianSelected = false;

                            WidgetsFlutterBinding.ensureInitialized();
                            runApp(MyApp());
                  
                            if (isMotherSelected == true) {
                              Fluttertoast.showToast(
                                msg: 'Mother Selected',
                                backgroundColor: Colors.black45,
                                textColor: Colors.white,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                            }
                          });
                        },
                        child: Container(
                          color:
                              isMotherSelected ? Colors.blue : Colors.transparent,
                          child: Row(
                            children: [
                              // Padding(
                              //   padding: EdgeInsets.zero,
                              //   child: Consumer(
                              //     builder: (context, ref, child) {
                              //       final isChecked = ref.watch(fatherCheckboxProvider);
                              //       return Checkbox(
                              //         value: isChecked,
                              //         onChanged: (newValue) {
                              //           ref.read(fatherCheckboxProvider.notifier).toggleFatherCheckbox();
                              //         },
                              //       );
                              //     },
                              //   ),
                              // ),

                              // Mother's image
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 0.0, right: 10.0),
                                child: Image.network(
                                  'https://sms.arnoldcentralschool.org/SACSv4test/uploads/parent_image/m_$qrCode.jpg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Handle error, for example, display a placeholder image
                                    return Image.asset(
                                      'assets/father.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              // Mother's name
                              Flexible(
                                child: Text(
                                  'Mother: ${studentData[0]['mother_name']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isMotherSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Display guardian's name
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // isFatherSelected = false;
                            // isMotherSelected = false;
                            isGuardianSelected = !isGuardianSelected;

                            WidgetsFlutterBinding.ensureInitialized();
                            runApp(MyApp());
                  
                            if (isGuardianSelected == true) {
                              Fluttertoast.showToast(
                                msg: 'Guardian Selected',
                                backgroundColor: Colors.black45,
                                textColor: Colors.white,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                              );
                            }
                          });
                        },
                        child: Container(
                          color: isGuardianSelected
                              ? Colors.blue
                              : Colors.transparent,
                          child: Row(
                            children: [
                              // Padding(
                              //   padding: EdgeInsets.zero,
                              //   child: Consumer(
                              //     builder: (context, ref, child) {
                              //       final isChecked = ref.watch(fatherCheckboxProvider);
                              //       return Checkbox(
                              //         value: isChecked,
                              //         onChanged: (newValue) {
                              //           ref.read(fatherCheckboxProvider.notifier).toggleFatherCheckbox();
                              //         },
                              //       );
                              //     },
                              //   ),
                              // ),
                              // Guardian's image
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 0.0, right: 10.0),
                                child: Image.network(
                                  'https://sms.arnoldcentralschool.org/SACSv4test/uploads/parent_image/g_$qrCode.jpg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Handle error, for example, display a placeholder image
                                    return Image.asset(
                                      'assets/father.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              // Guardian's name
                              Flexible(
                                child: Text(
                                  'Guardian: ${studentData[0]['guardian_name']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isGuardianSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      // Display each student's details
                      for (var data in studentData)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student image
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Image.network(
                                'https://sms.arnoldcentralschool.org/SACSv4test/uploads/student_image/${data['student_id']}.jpg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle error, for example, display a placeholder image
                                  return Image.asset(
                                    'assets/father.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            // Student name
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  '${data['first_name']} ${data['mid_name']} ${data['last_name']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                subtitle: Text(
                                  'Class: ${data['class_name']}-${data['sec_name']}',
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Navigator.of(context).pop(); // Close the dialog

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryTab()),
                  );
                },
                child: Text('Close'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  // Get current date and time
                  DateTime now = DateTime.now();

                  // Format date (dd-mm-yyyy)
                  String formattedDate = DateFormat('dd-MM-yyyy').format(now);

                  // Format time (hh:mm:ss)
                  String formattedTime = DateFormat('HH:mm:ss').format(now);

                  // Print the formatted date and time
                  print('Formatted Date: $formattedDate');
                  print('Formatted Time: $formattedTime');


                  String visitBy = '';

                  if (isFatherSelected) {
                    visitBy += 'Father,';
                  }

                  if (isMotherSelected) {
                    visitBy += 'Mother,';
                  }

                  if (isGuardianSelected) {
                    visitBy += 'Guardian';
                  }

                  // Remove trailing comma, if any
                  if (visitBy.isNotEmpty && visitBy.endsWith(',')) {
                    visitBy = visitBy.substring(0, visitBy.length - 1);
                  }

                  print('Visit By: $visitBy');

                  if(visitBy.isEmpty){

                    Fluttertoast.showToast(
                      msg: 'Please Select Parent, Who Are On Gate!!',
                      backgroundColor: Colors.black45,
                      textColor: Colors.white,
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                    );

                  } else {
                    IN(teacherApkUrl, shortName, qrCode, academic_yr,
                        formattedDate, formattedTime,context,visitBy);
                  }
                },
                child: Text(
                  'IN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}

void IN(String teacherApkUrl, String shortName, String qrCode,
    String academic_yr, String formattedDate, String formattedTime, BuildContext context, String visitBy) async {
  try {
    http.Response response = await post(
      Uri.parse(teacherApkUrl + "AdminApi/" + SAVE),
      body: {
        'short_name': shortName,
        'parent_id': qrCode,
        'acd_yr': academic_yr,
        'visit_date': formattedDate,
        'visit_by': visitBy,
        'visit_in_time': formattedTime
      },
    );

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'Parent IN: Visitors Data Saved Successfully!!',
        backgroundColor: Colors.black45,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HistoryTab()),
      );

    }
  } catch (e) {
    print('Exception: $e');
  }
}
