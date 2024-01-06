import 'package:find_any_flutter/soc_admin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Import your login screen

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // After signing out, navigate the user to the login screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {})),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Function to navigate to another page
  void _navigateToOtherPage() {
    // Implement your navigation logic here
    print('Navigate to other page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Add a row to occupy two images in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SocAdminPage()),
                  );
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/KLU_LOGO.png', // Replace with your image asset path
                        width: 150, // Adjust the width as needed
                        height: 150, // Adjust the height as needed
                      ),
                    ),
                    Text(
                      'SOC',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SocAdminPage()),
                  );
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/FindAnyLogo.png', // Replace with your second image asset path
                        width: 150, // Adjust the width as needed
                        height: 150, // Adjust the height as needed
                      ),
                    ),
                    Text(
                      'FIND ANY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Your other content goes here
          Expanded(
            child: Container(),  // Replace this with your actual content or widgets
          ),

          ElevatedButton(
            onPressed: _signOut,
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
