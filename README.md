# Firebase Flutter CRUD implementation

ICT602 - MOBILE TECHNOLOGY AND DEVELOPMENT

This Flutter app demonstrates a simple restaurant application with Firebase integration. It includes user authentication, menu management, and user profiles.

## Features

- User Authentication
  - Sign up and login with Firebase Authentication
  - Admin and normal user roles
- Menu Management
  - Display food and drink menu items
  - Admin-only access to menu management
  - food/drink availability control
- User Profile
  - Users can update their profiles
 
## CRUD Operations

The app includes basic CRUD (Create, Read, Update, Delete) operations. Here are snippets of the relevant code:

### Create Operation

Create user account
```dart
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
```
Create food item
```dart
//create food item
  Future<void> _addDataToFirestore(String data, double price) async {
    try {
      await _firestore.collection('makanan').add({
        'field1': data,
        'field2': 'food',
        'isAvailable': true,
        'price': price, // Add the price to the document
      });
      _textFieldController.clear();
    } catch (e) {
      print('Error adding data: $e');
    }
  }
```
Create drink item
```dart
//create food item
  Future<void> _addDataToFirestore(String data, double price) async {
    try {
      await _firestore.collection('makanan').add({
        'field1': data,
        'field2': 'food',
        'isAvailable': true,
        'price': price, // Add the price to the document
      });
      _textFieldController.clear();
    } catch (e) {
      print('Error adding data: $e');
    }
  }
```

### Read Operation

Read user data
```dart
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
```
Read menu item
```dart
 @override
  void initState() {
    super.initState();
    // Fetch initial data
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    await _loadMenu('makanan', foodMenu);
    await _loadMenu('minuman', drinkMenu);
  }

  Future<void> _loadMenu(String collection, List<MenuItem> menu) async {
  final firestore = FirebaseFirestore.instance;
  firestore.collection(collection).snapshots().listen((snapshot) {
    final menuItems = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MenuItem(
        name: data['field1'],
        description: data['field2'],
        price: data['price'], 
        isAvailable: data['isAvailable'] ?? true,
      );
    }).toList();

    setState(() {
      menu.clear();
      menu.addAll(menuItems);
    });
  });
```

### Update Operation

Update user profile
```dart
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
```

Update food menu
```dart
Future<void> _updateDataInFirestore(String documentId, String currentField1, bool? isAvailable) async {
    final TextEditingController _updateField1Controller = TextEditingController(text: currentField1);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _updateField1Controller,
                decoration: InputDecoration(labelText: 'New Field1 Value'),
              ),
              Text('Is Available: ${isAvailable ?? false}'), // Display the current availability status
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedField1 = _updateField1Controller.text;
                await _firestore.collection('makanan').doc(documentId).update({
                  'field1': updatedField1,
                });
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('makanan').doc(documentId).update({
                  'isAvailable': !(isAvailable ?? false), // Toggle the availability status in Firestore
                });
                Navigator.of(context).pop();
              },
              child: Text('Toggle Availability'),
            ),
          ],
        );
      },
    );
  }

  void _showPriceDialog(String documentId, double currentPrice) {
    final TextEditingController _priceController = TextEditingController(text: currentPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'New Price'),
                keyboardType: TextInputType.number, // Allowing only numbers
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newPrice = double.tryParse(_priceController.text);
                if (newPrice != null) {
                  _updatePriceInFirestore(documentId, newPrice);
                  Navigator.of(context).pop();
                } else {
                  // Handle invalid input or display a message to the user.
                }
              },
              child: Text('Update Price'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePriceInFirestore(String documentId, double newPrice) async {
    await _firestore.collection('makanan').doc(documentId).update({
      'price': newPrice,
    });
  }
```
Update drink menu
```dart
Future<void> _updateDataInFirestore(String documentId, String currentField1, bool? isAvailable) async {
    final TextEditingController _updateField1Controller = TextEditingController(text: currentField1);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _updateField1Controller,
                decoration: InputDecoration(labelText: 'New Field1 Value'),
              ),
              Text('Is Available: ${isAvailable ?? false}'), // Display the current availability status
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedField1 = _updateField1Controller.text;
                await _firestore.collection('minuman').doc(documentId).update({
                  'field1': updatedField1,
                });
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('minuman').doc(documentId).update({
                  'isAvailable': !(isAvailable ?? false), // Toggle the availability status in Firestore
                });
                Navigator.of(context).pop();
              },
              child: Text('Toggle Availability'),
            ),
          ],
        );
      },
    );
  }

  void _showPriceDialog(String documentId, double currentPrice) {
    final TextEditingController _priceController = TextEditingController(text: currentPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'New Price'),
                keyboardType: TextInputType.number, // Allowing only numbers
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newPrice = double.tryParse(_priceController.text);
                if (newPrice != null) {
                  _updatePriceInFirestore(documentId, newPrice);
                  Navigator.of(context).pop();
                } else {
                  // Handle invalid input or display a message to the user.
                }
              },
              child: Text('Update Price'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePriceInFirestore(String documentId, double newPrice) async {
    await _firestore.collection('minuman').doc(documentId).update({
      'price': newPrice,
    });
  }
```

### Delete Operation

Delete food menu
```dart
  Future<void> _deleteDataFromFirestore(String documentId) async {
    await _firestore.collection('makanan').doc(documentId).delete();
  }
```

Delete drink menu
```dart
  Future<void> _deleteDataFromFirestore(String documentId) async {
    await _firestore.collection('minuman').doc(documentId).delete();
  }
```













