import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  final User user;

  UserProfileScreen({required this.user});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _image;

  @override
  void initState() {
    super.initState();
    // Fetch the user's profile data from Firestore
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.user.uid).get();

      if (userDoc.exists) {
        final userProfile = userDoc.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = userProfile['name'] ?? '';
          mobileController.text = userProfile['mobile'] ?? '';
        });
      }
    } catch (e) {
      // Handle errors, e.g., display an error message
      print('Error fetching user profile data: $e');
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      await _firestore.collection('users').doc(widget.user.uid).set({
        'name': nameController.text,
        'mobile': mobileController.text,
      }, SetOptions(merge: true));
      // Handle successful update, e.g., show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully'),
      ));
    } catch (e) {
      // Handle errors, e.g., display an error message
      print('Error updating profile: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
  onTap: _pickImage,
  child: CircleAvatar(
    radius: 60,
    backgroundImage: _image != null
        ? FileImage(_image!) as ImageProvider<Object>?
        : NetworkImage('https://th.bing.com/th/id/OIP.Xul8xb_RKpJd0BhazsiY3QHaHa?rs=1&pid=ImgDetMain') as ImageProvider<Object>?,
  ),
),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUserProfile();
              },
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
