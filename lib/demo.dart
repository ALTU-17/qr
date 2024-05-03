
import 'package:flutter/material.dart';

class SingUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/img.png', // Replace with your actual background image path
              fit: BoxFit.cover,
            ),
          ),
          // Login form with custom-shaped background
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: TopCurvedClipper(), // Use the custom clipper here
              child: Container(
                color: Colors.white,
                padding:
                EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'UserName',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.of(context).pushNamed(loginPage);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.blueAccent, // Button background color
                        shape: StadiumBorder(),
                        padding:
                        EdgeInsets.symmetric(horizontal: 72, vertical: 12),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0,
        40); // Start from the left corner and draw a line to the point where the curve starts
    path.quadraticBezierTo(
        size.width / 2, 0, size.width, 40); // Create a quadratic bezier curve
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TopCurvedClipper oldClipper) => false;
}