import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );

      // Pass the user's email to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userEmail: usernameController.text),
        ),
      );
    } catch (e) {
      // Handle login errors, e.g., display an error message
      print('Login error: $e');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the Google Sign-In process
        return;
      }

      // Get Google Sign-In authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using Google credentials
      await _auth.signInWithCredential(credential);

      // Pass the user's email to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(userEmail: _auth.currentUser?.email ?? ""),
        ),
      );
    } catch (e) {
      print('Google Sign-In error: $e');
    }
  }

  void navigateToRegister() {
    // Navigate to the registration screen
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/p1.jpg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: usernameController,
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
                  login();
                },
                child: Text('Login'),
              ),
              ElevatedButton(
                onPressed: _handleGoogleSignIn,
                child: Text('Login with Google'),
              ),
              TextButton(
                onPressed: navigateToRegister,
                child: Text('Not registered yet? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
