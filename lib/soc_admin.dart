import 'package:find_any_flutter/soc_admin_seating_arrangment.dart';
import 'package:find_any_flutter/soc_students.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocAdminPage extends StatefulWidget {
  @override
  _SocAdminPageState createState() => _SocAdminPageState();
}

class _SocAdminPageState extends State<SocAdminPage> {
  TextEditingController _text1EditingController = TextEditingController();
  TextEditingController _text2EditingController = TextEditingController();
  TextEditingController _text3EditingController = TextEditingController();

  String selectedValue1 = 'Option 1';
  String selectedValue2 = 'Option A';
  List<String> savedTexts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soc Admin Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddTextDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildSavedTextButtons(),
        ],
      ),
    );
  }

  Future<void> _showAddTextDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter Texts',
            style: TextStyle(fontSize: 20, fontFamily: 'Roboto'),
          ),
          content: Container(
            constraints: BoxConstraints(maxHeight: 300), // Set a maximum height
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _text1EditingController,
                    decoration: InputDecoration(labelText: 'Enter the Name'),
                  ),
                  TextField(
                    controller: _text2EditingController,
                    decoration: InputDecoration(
                        labelText: 'Enter the date of Examination'),
                  ),
                  TextField(
                    controller: _text3EditingController,
                    decoration: InputDecoration(
                        labelText: 'Enter the Time of the Examination'),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: DropdownButton<String>(
                      value: selectedValue1,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue1 = newValue!;
                        });
                      },
                      items: <String>[
                        'Option 1',
                        'Option 2',
                        'Option 3',
                        'Option 4'
                      ].map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: DropdownButton<String>(
                      value: selectedValue2,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue2 = newValue!;
                        });
                      },
                      items: <String>[
                        'Option A',
                        'Option B',
                        'Option C',
                        'Option D'
                      ].map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String enteredText1 = _text1EditingController.text;
                String enteredText2 = _text2EditingController.text;
                String enteredText3 = _text3EditingController.text;

                print('Entered Text 1: $enteredText1');
                print('Entered Text 2: $enteredText2');
                print('Entered Text 3: $enteredText3');
                print('Selected Value 1: $selectedValue1');
                print('Selected Value 2: $selectedValue2');

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavedTextButtons() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('SOC_FILES').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var documents = snapshot.data!.docs;
          savedTexts = documents.map((document) => document.id).toList();
          print("List: $savedTexts");

          return ListView.builder(
            shrinkWrap: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              var text = document.id; // Use the document ID as the button text
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SocAdminSeatingArrangement(documentname: text),
                          ),
                        );
                      },
                      child: Text(text),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteText(index);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _deleteText(int index) async {
    try {
      // Check if the index is within the valid range
      if (index >= 0 && index < savedTexts.length) {
        var document = FirebaseFirestore.instance
            .collection('SOC_FILES')
            .doc(savedTexts[index]);

        // Delete the document from Firestore
        await document.delete();

        // Remove the document name from the local list
        setState(() {
          savedTexts.removeAt(index);
        });
      } else {
        print('Invalid index: $index');
      }
    } catch (e, stackTrace) {
      print('Error deleting document from Firestore: $e');
      print('Error Stack Trace: $stackTrace');
    }
  }

  Future<void> _saveToFirestore(String text) async {
    try {
      print('Saving to Firestore: $text');

      // Firestore initialization
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Collection reference
      CollectionReference socFilesCollection =
          firestore.collection('SOC_FILES');

      // Explicitly set the document name as the entered text
      DocumentReference documentReference = socFilesCollection.doc(text);

      await documentReference.set({
        'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
      });

      print('Document added to Firestore with ID: ${documentReference.id}');
    } catch (e, stackTrace) {
      print('Error adding document to Firestore: $e');
      print('Error Stack Trace: $stackTrace');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: SocAdminPage(),
  ));
}
