import 'package:find_any_flutter/soc_admin_seating_arrangment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocAdminPage extends StatefulWidget {
  @override
  _SocAdminPageState createState() => _SocAdminPageState();
}

class _SocAdminPageState extends State<SocAdminPage> {
  TextEditingController _textEditingController = TextEditingController();
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
          title: Text('Enter Text'),
          content: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(labelText: 'Type something...'),
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
                String enteredText = _textEditingController.text;
                print('Entered Text: $enteredText');

                // Add the entered text to the beginning of the list
                setState(() {
                  savedTexts.insert(0, enteredText);
                });

                // Save to Firestore
                await _saveToFirestore(enteredText);

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
                            builder: (context) => SocAdminSeatingArrangement(documentname: text),
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
        var document = FirebaseFirestore.instance.collection('SOC_FILES').doc(savedTexts[index]);

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
      CollectionReference socFilesCollection = firestore.collection('SOC_FILES');

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
