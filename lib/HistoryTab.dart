import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:qr/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProfileTab.dart';
import 'Scanner.dart';

class Visitor {
  final String parentId;
  final String visit_by;
  final String guardian_name;
  final String fatherName;
  final String fatherOccupation;
  final String fatherOfficeAddress;
  final String fatherMobile;
  final String fatherEmail;

  final String mothername;
  final String motherOccupation;
  final String motherOfficeAddress;
  final String motherMobile;
  final String motherEmail;
  final String parentAdharNo;
  final String fatherImageName;
  final String motherImageName;
  final String visitorId;
  final String academicYear;
  final String visitDate;
  final String visitInTime;
  final String visitOutTime;

  Visitor({
    required this.parentId,
    required this.visit_by,
    required this.guardian_name,
    required this.fatherName,
    required this.fatherOccupation,
    required this.fatherOfficeAddress,
    required this.fatherMobile,
    required this.fatherEmail,
    required this.mothername,
    required this.motherOccupation,
    required this.motherOfficeAddress,
    required this.motherMobile,
    required this.motherEmail,
    required this.parentAdharNo,
    required this.fatherImageName,
    required this.motherImageName,
    required this.visitorId,
    required this.academicYear,
    required this.visitDate,
    required this.visitInTime,
    required this.visitOutTime,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      parentId: json['parent_id'],
      visit_by: json['visit_by'],
      guardian_name: json['guardian_name'],
      fatherName: json['father_name'],
      fatherOccupation: json['father_occupation'],
      fatherOfficeAddress: json['f_office_add'],
      fatherMobile: json['f_mobile'],
      fatherEmail: json['f_email'],
      mothername: json['mother_name'],
      motherOccupation: json['mother_occupation'],
      motherOfficeAddress: json['m_office_add'],
      motherMobile: json['m_mobile'],
      motherEmail: json['m_emailid'],
      parentAdharNo: json['parent_adhar_no'],
      fatherImageName: json['father_image_name'],
      motherImageName: json['mother_image_name'],
      visitorId: json['visitor_id'],
      academicYear: json['academic_yr'],
      visitDate: json['visit_date'],
      visitInTime: json['visit_in_time'],
      visitOutTime: json['visit_out_time'],
    );
  }
}

class HistoryTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HistoryTab();
}

class _HistoryTab extends State<HistoryTab> {
  List<Visitor> visitors = []; // Initialize an empty list of Visitor objects
  bool isLoading = true; // New state variable to track loading state
  String academic_yr="";
  @override
  void initState() {
    super.initState();
    fetchVisitorData();
  }

  Future<void> fetchVisitorData() async {
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
    String user_id = logUrls_Paresedata['user_id'];

    // Access individual values from the parsed data
     academic_yr = logUrls_Paresedata['academic_yr'];

    try {
      http.Response response = await http.post(
        Uri.parse(teacherApkUrl + 'AdminApi/'+LIST),
        body: {
          'short_name': shortName,
          'acd_yr': academic_yr
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response get visitors data=> : ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        String jj = response.body;
        setState(() {
          isLoading = false;
        });



        // Parse the JSON string
        Map<String, dynamic> responseData = jsonDecode(jj);

// Access the status field and store it in a string
        String status = responseData['status'].toString();

        print('statusss==> $status');
// Now you can use the status string for validation
        if (status == 'false') {
          // Handle the case where status is false
          setState(() {
          isLoading = false;
          });


          Fluttertoast.showToast(
            msg: 'No Records Found',
            backgroundColor: Colors.black45,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,

          );

           Center(
            child: Text(
              'No visitors found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

        } else {

          // Handle other cases
          final List<dynamic> visitorList = jsonResponse['visiting_data'];

          // Use a Set to keep track of unique visitor IDs
          Set<String> uniqueVisitorIds = Set<String>();

          // Filter out duplicate visitors based on visitor_id
          List<Visitor> uniqueVisitors = [];

          for (var json in visitorList) {
            Visitor visitor = Visitor.fromJson(json);
            if (!uniqueVisitorIds.contains(visitor.visitorId)) {
              uniqueVisitorIds.add(visitor.visitorId);
              uniqueVisitors.add(visitor);
            }
          }

          setState(() {
            isLoading = false;
            visitors = uniqueVisitors;
          });
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  @override
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => QRScanPage()),
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
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
              ),
              IconButton(
                icon: Icon(Icons.person_pin_rounded),
                onPressed: () {

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileTab()),
                  );

                  // Handle notification button press
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/img.png', // Replace with your background image
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : visitors != null
                    ? ListView.builder(
                        itemCount: visitors.length,
                        itemBuilder: (context, index) {
                          final visitor = visitors[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Visit ID: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          visitor.visitorId,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Visit By: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          visitor.visit_by,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          visitor.visit_by == 'Mother' ? 'Mother Name: ' :
                                          visitor.visit_by == 'Father' ? 'Father Name: ' :
                                          visitor.visit_by == 'Father,Mother' ? 'Father Name: ' +"\n" + 'Mother Name: ':
                                          visitor.visit_by == 'Mother,Father' ? 'Father Name: ' +"\n" + 'Mother Name: ':
                                          visitor.visit_by == 'Guardian' ? 'Guardian Name: ' :
                                          visitor.visit_by == 'Father,Guardian' ? 'Father Name: ' +"\n" + 'Guardian Name: ' :
                                          visitor.visit_by == 'Mother,Guardian' ? 'Mother Name: ' +"\n" + 'Guardian Name: ' : '',

                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            height: 2
                                          ),
                                        ),

                                        Visibility(
                                          visible: visitor.visit_by == 'Mother',
                                          child: Text(
                                            visitor.mothername,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Visibility(
                                          visible: visitor.visit_by == 'Father',
                                          child: Text(
                                            visitor.fatherName,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Visibility(
                                          visible: visitor.visit_by == 'Father,Mother',
                                          child: Text(
                                            visitor.fatherName +"\n"+ visitor.mothername,
                                            style: TextStyle(fontSize: 14,height: 2),
                                          ),
                                        ),
                                        Visibility(
                                          visible: visitor.visit_by == 'Mother,Father',
                                          child: Text(
                                            visitor.fatherName +"\n"+ visitor.mothername,
                                            style: TextStyle(fontSize: 14,height: 2),
                                          ),
                                        ),
                                        Visibility(
                                          visible: visitor.visit_by == 'Guardian',
                                          child: Text(
                                            visitor.guardian_name,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Visibility(
                                          visible: visitor.visit_by == 'Mother,Guardian',
                                          child: Text(
                                            visitor.mothername +"\n"+ visitor.guardian_name,
                                            style: TextStyle(fontSize: 14,height: 2),
                                          ),
                                        ),
                                        Visibility(
                                          visible: visitor.visit_by == 'Father,Guardian',
                                          child: Text(
                                            visitor.fatherName +"\n"+ visitor.guardian_name,
                                            style: TextStyle(fontSize: 14,height: 2 ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          'Visit Date: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd-MM-yyyy').format(DateTime.parse(visitor.visitDate)),
                                          style: TextStyle(fontSize: 14),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Visit In Time: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,

                                          ),
                                        ),
                                        Text(
                                          visitor.visitInTime,
                                          style: TextStyle(fontSize: 14, color: Colors.green,),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Visit Out Time: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,

                                          ),
                                        ),
                                        Text(
                                          visitor.visitOutTime,
                                          style: TextStyle(fontSize: 14,color: Colors.red,),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    if (visitor.visitOutTime == '00:00:00')
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          String visi = visitor.parentId;
                                          _handleOUT(context,visi);

                                          // Handle OUT button press
                                        },
                                        child: Text(
                                          'OUT',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text('No visitors found', style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
          ),
      // Positioned(
      //   bottom: 25,
      //   left: 0,
      //   right: 0,
      //   child: FloatingActionButton(
      //     onPressed: () {
      //
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (_) => QRScanPage()),
      //       );
      //       // Handle your action when FAB is pressed
      //     },
      //     backgroundColor: Colors.blue,
      //     shape: CircleBorder(),
      //
      //     child: Icon(Icons.qr_code),
      //   ),
      // ),
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
        child: Icon(Icons.qr_code,color: Colors.black,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );

  }

}
Future<bool> _confirmOUT(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirm OUT'),
      content: Text('Do you want to OUT this parent?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // Return false (don't pop) when 'No' is pressed
          },
          child: Text('No'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            Navigator.pop(context, true); // Return true (pop) when 'Yes' is pressed
          },
          child: Text('Out',style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  ) ?? false; // Return false if dialog is dismissed without pressing any button
}

void _handleOUT(BuildContext context,String visi) async {
  bool confirmOUT = await _confirmOUT(context);
  if (confirmOUT) {
    DateTime now = DateTime.now();
    // Format date (dd-mm-yyyy)
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    // Format time (hh:mm:ss)
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    final prefs = await SharedPreferences.getInstance();

    String? school_info = prefs.getString('school_info');

    Map<String, dynamic> parsedData = json.decode(school_info!);

    String? logUrls = prefs.getString('logUrls');

    Map<String, dynamic> logUrls_Paresedata = json.decode(logUrls!);

    OUT1(
      context,
      parsedData['teacherapk_url'],
      parsedData['short_name'],
      visi,
      logUrls_Paresedata['academic_yr'],
      formattedDate,
      formattedTime,
    );
    // Perform the OUT action here
  }
}
void OUT1(BuildContext context,String teacherApkUrl, String shortName, String qrCode,
    String academic_yr, String formattedDate, String formattedTime) async {

  try {
    http.Response response = await post(
      Uri.parse(teacherApkUrl +"AdminApi/"+ OUTV),
      body: {
        'short_name': shortName,
        'parent_id': qrCode,
        'acd_yr': academic_yr,
        'visit_date': formattedDate,
        'visit_out_time': formattedTime
      },
    );

    print('Response body: $qrCode $academic_yr $formattedTime $formattedDate');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {

      Fluttertoast.showToast(
        msg: 'Parent OUT: Updated Visitors Out Time!!',
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

