import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPage extends StatefulWidget {
  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _textFieldController = TextEditingController();

  //create food item
  Future<void> _addDataToFirestore(String data, double price) async {
    try {
      await _firestore.collection('caterings').add({
        'field1': data,
        'field2': 'Food',
        'isAvailable': true,
        'price': price, // Add the price to the document
      });
      _textFieldController.clear();
    } catch (e) {
      print('Error adding data: $e');
    }
  }

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
                decoration: InputDecoration(labelText: 'Food Name'),
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
                await _firestore.collection('caterings').doc(documentId).update({
                  'field1': updatedField1,
                });
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('caterings').doc(documentId).update({
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
    await _firestore.collection('caterings').doc(documentId).update({
      'price': newPrice,
    });
  }

  Future<void> _deleteDataFromFirestore(String documentId) async {
    await _firestore.collection('caterings').doc(documentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catering'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _textFieldController,
              decoration: InputDecoration(
                labelText: 'Add Catering',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _addDataToFirestore(_textFieldController.text, 0.0); // Initialize with a price of 0.0
              },
              child: Text('Add Data'),
            ),
            SizedBox(height: 20),
            Text(
              'Firestore Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('caterings').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final document = data[index].data() as Map<String, dynamic>;
                        final documentId = data[index].id;
                        final currentPrice = document['price'] ?? 0.0; // Get the price or default to 0.0
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(document['field1']),
                            subtitle: Text(document['field2']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _updateDataInFirestore(documentId, document['field1'], document['isAvailable']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.attach_money), // Add an icon for changing the price
                                  onPressed: () {
                                    _showPriceDialog(documentId, currentPrice);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteDataFromFirestore(documentId);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Text('No data available');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
