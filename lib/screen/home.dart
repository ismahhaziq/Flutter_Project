import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user.dart';
import 'menu.dart';

class HomeScreen extends StatelessWidget {
  final String userEmail;

  HomeScreen({required this.userEmail});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
          context, '/login'); // Navigate back to the login screen
    } catch (e) {
      // Handle errors, e.g., display an error message
      print('Sign-out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Home!'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    user: FirebaseAuth.instance.currentUser!,
                  ),
                ),
              );
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://as1.ftcdn.net/v2/jpg/03/53/11/00/1000_F_353110097_nbpmfn9iHlxef4EDIhXB1tdTD0lcWhG9.jpg'),
            ),
            SizedBox(height: 20),
            Text(
              'Hello,',
              style: TextStyle(fontSize: 24),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$userEmail',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuPage(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Explore Service',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _signOut(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
