import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerUser(BuildContext context) async {
    try {
      final String email = emailController.text;
      final String password = passwordController.text;

      // Create a user with email and password using Firebase Authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Registration successful, show a snackbar
        final snackBar = SnackBar(
          content: Text('Registration successful. You can now log in.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // You can also navigate to the login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Handle registration failure, if necessary
      }
    } catch (e) {
      // Handle registration errors, e.g., display an error message
      print('Registration error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                registerUser(context); // Call the registration function
              },
              child: Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login screen
              },
              child: Text('Already registered? Login here'),
            ),
          ],
        ),
      ),
    );
  }
}
