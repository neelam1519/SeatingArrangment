import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'PdfGenerator.dart';

class SocAdminSeatingArrangement extends StatefulWidget {
  final String documentname;

  SocAdminSeatingArrangement({required this.documentname});

  @override
  _SocAdminSeatingArrangementState createState() =>
      _SocAdminSeatingArrangementState();
}

class _SocAdminSeatingArrangementState
    extends State<SocAdminSeatingArrangement> {
  GlobalKey<ProgressDialogState> progressDialogKey =
      GlobalKey<ProgressDialogState>();

  Map<String, List<String>> batchesMap = {'Batch 1': []};
  String selectedBatch = 'Batch 1'; // Track the selected batch
  List<Widget> batchWidgets = [];
  List<Widget> FileWidgets = [];
  bool isSubmitFilesVisible = false;
  bool isArrangeVisible = false;
  bool isReportVisible = false;
  Map<String, File> uploadedFiles = {};
  Map<String, String> uploadedFilesLinks = {};
  bool _isLoading = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seating Arrangement - ${widget.documentname}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20), // Add some space between AppBar and Text
            Text(
              'Think as a bench',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // Add some space between Text and Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _handleSeatingButtonClick('Seat 1');
                  },
                  child: Text('Seat 1'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _handleSeatingButtonClick('Seat 2');
                  },
                  child: Text('Seat 2'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _handleSeatingButtonClick('Seat 3');
                  },
                  child: Text('Seat 3'),
                ),
              ],
            ),
            SizedBox(
                height:
                    20), // Add some space between Buttons and TextView + Button
            Column(
              children: batchesMap.keys
                  .map(
                    (batch) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20), // Add space to the left
                          child:
                              Text('$batch: ${batchesMap[batch]!.join(', ')}'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right: 20), // Add space to the right
                          child: ElevatedButton(
                            onPressed: () {
                              _handleOkButtonClick(batch);
                            },
                            child: Text('OK'),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 20), // Add some space between TextView and Buttons
            ElevatedButton(
              onPressed: () {
                _removeEmptyBatches();
                _updateFirestore();
                _createBatchWidgets();
                setState(() {
                  // Set the visibility of "Submit Files" button to false
                  isSubmitFilesVisible = true;
                });
              },
              child: Text('Submit Batches'),
            ),
            SizedBox(height: 20), // Add space before batch widgets
            // Display batch widgets
            ...batchWidgets,
            // "Submit Files" button with visibility control
            Visibility(
              visible: isSubmitFilesVisible,
              child: ElevatedButton(
                onPressed: () {
                  _uploadFilesToStorage(); // Corrected line: Invoke the function
                  setState(() {
                    // Set the visibility of the new button to true
                    isArrangeVisible = true;
                  });
                },
                child: Text('Submit Files'),
              ),
            ),
            SizedBox(height: 20), // Add some space before file widgets
            // Display dynamic file widgets
            ...FileWidgets,
            Visibility(
              visible: isArrangeVisible,
              child: ElevatedButton(
                onPressed: () {
                  _ArrangeStudentsSeating();
                },
                child: Text('Arrange'),
              ),
            ),
            Visibility(
              visible: isReportVisible,
              child: ElevatedButton(
                onPressed: () {
                  _createPDF();
                },
                child: Text('Create Report'),
              ),
            ),
            Visibility(
              visible: isReportVisible,
              child: ElevatedButton(
                onPressed: () {
                  _createPDF();
                },
                child: Text('Search Students'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPDF() async {
    // Create a new PDF document
    PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();

    StringGenerator(document, page, "2022", "2023", "SE 1");

    // Save the document
    List<int> bytes = await document.save();

    saveAndLaunch(bytes, widget.documentname, 'Output.pdf');

    // Dispose the document
    document.dispose();
  }

  void _ArrangeStudentsSeating() async {
    Map<String, List<List<dynamic>>> seatDataMap = {}; // Map to store seat data
    List<List<dynamic>> batch1 = [];
    List<List<dynamic>> batch2 = [];
    List<List<dynamic>> batch3 = [];
    int totalBenches = 15;

    List<List<dynamic>> classrooms =
        await readCsv(uploadedFiles["HallNumbers"]!);
    List<List<dynamic>> lecturers =
        await readCsv(uploadedFiles["LecturerNames"]!);

    await Future.forEach(batchesMap.entries,
        (MapEntry<String, List<String>> entry) async {
      String batchKey = entry.key;
      List<String> values = entry.value;

      if (uploadedFiles.containsKey(batchKey)) {
        int numberOfValues = values.length;
        File file = uploadedFiles[batchKey]!;

        List<List<dynamic>> all = await readCsv(file);
        if (allKeysHaveOneValueAndTwoOrMoreKeys()) {
          print("test 1");
          if (batchesMap.length == 2) {
            print("test 2");
            if (batchKey == "Batch 1") {
              batch1.add(all);
            } else if (batchKey == "Batch 2") {
              batch3.add(all);
            }
          } else if (batchesMap.length == 3) {
            print("test 3");
            if (batchKey == "Batch 1") {
              batch1.add(all);
            } else if (batchKey == "Batch 2") {
              batch2.add(all);
            } else if (batchKey == "Batch 3") {
              batch3.add(all);
            }
          }
        } else if (numberOfValues == 1) {
          print("test 4");
          batch2.addAll(all);
          print(batch2.length);
        } else if (numberOfValues == 2) {
          print("test 5");
          // Do something specific for batches with 2 values
          _splitInto2(all, batch1, batch3);
        } else if (numberOfValues == 3) {
          print("test 6");
          // Do something specific for batches with 3 values
          _splitInto3(all, batch1, batch2, batch3);
        }
      }
    });

    print("Batch 1 Length: ${batch1.length}");
    print("Batch 2 Length: ${batch2.length}");
    print("Batch 3 Length: ${batch3.length}");
    _assignStudentsToClassrooms(batch1, batch2, batch3, classrooms, lecturers);
  }

  Future<void> _assignStudentsToClassrooms(
      List<List<dynamic>> batch1,
      List<List<dynamic>> batch2,
      List<List<dynamic>> batch3,
      List<List<dynamic>> classrooms,
      List<List<dynamic>> lecurernames) async {
    int batch1Counter = 0;
    int batch2Counter = 0;
    int batch3Counter = 0;

    int totalIterations = classrooms.length * 45;
    int currentIteration = 0;

    List<String> Blocks = [];

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(key: progressDialogKey, progress: _progress);
        },
      );

      for (int i = 0; i < classrooms.length; i++) {
        List<dynamic> classroom = classrooms[i];
        List<dynamic> lecturer = lecurernames[i];

        String lecturerName = lecturer[0];

        int classroomNumber = classroom[0];
        int classroomCapacity = classroom[1];

        String blockNumber = await _blockNumber(classroomNumber.toString());
        String classNumber = await _classnumber(classroomNumber.toString());

        Blocks.add(blockNumber);
        await uploadLecturerName("SOC_FILES", widget.documentname, blockNumber,
            classNumber, "LecturerName", lecturerName);

        for (int j = 0; j < classroomCapacity; j++) {
          int benchNumber = (j ~/ 3) + 1;
          String studentPosition = String.fromCharCode((j % 3) + 97);
          String position = '$benchNumber$studentPosition';

          if (j % 3 == 0) {
            currentIteration++;
            if (batch1Counter < batch1.length) {
              batch1[batch1Counter].add(position);
              await uploadData(
                "SOC_FILES",
                widget.documentname,
                blockNumber,
                classNumber,
                batch1[batch1Counter][0].toString(),
                batch1[batch1Counter],
              );
              batch1Counter++;
            }
          } else if (j % 3 == 1) {
            currentIteration++;
            if (batch2Counter < batch2.length) {
              batch2[batch2Counter].add(position);
              await uploadData(
                "SOC_FILES",
                widget.documentname,
                blockNumber,
                classNumber,
                batch2[batch2Counter][0].toString(),
                batch2[batch2Counter],
              );
              batch2Counter++;
            }
          } else {
            currentIteration++;
            if (batch3Counter < batch3.length) {
              batch3[batch3Counter].add(position);
              await uploadData(
                "SOC_FILES",
                widget.documentname,
                blockNumber,
                classNumber,
                batch3[batch3Counter][0].toString(),
                batch3[batch3Counter],
              );
              batch3Counter++;
            }
          }
          // Update progress
          setState(() {
            _progress = currentIteration / totalIterations;
            progressDialogKey.currentState?.updateProgress(_progress);
          });
        }
      }
      await uploadList("SOC_FILES", widget.documentname, "blocks", Blocks);
    } catch (error) {
      print("Error during assignment: $error");
    } finally {
      // Close the progress dialog when done or in case of an error
      Navigator.pop(context);
      isReportVisible = true;
    }
  }

  Future<void> uploadData(
      String collectionName,
      String documentName,
      String subcollectionName,
      String subdocumentName,
      String fieldName,
      List<dynamic> value) async {
    // Reference to Firestore collection, document, subcollection, and subdocument
    CollectionReference collection =
        FirebaseFirestore.instance.collection(collectionName);
    DocumentReference document = collection.doc(documentName);
    CollectionReference subcollection =
        document.collection(subcollectionName.toString());
    DocumentReference subdocument =
        subcollection.doc(subdocumentName.toString());

    // Upload data to Firestore
    await subdocument.set({
      fieldName: FieldValue.arrayUnion(value),
      // Add other fields as needed
    }, SetOptions(merge: true));
  }

  Future<void> uploadLecturerName(
      String collectionName,
      String documentName,
      String subcollectionName,
      String subdocumentName,
      String fieldName,
      String value) async {
    // Reference to Firestore collection, document, subcollection, and subdocument
    CollectionReference collection =
        FirebaseFirestore.instance.collection(collectionName);
    DocumentReference document = collection.doc(documentName);
    CollectionReference subcollection =
        document.collection(subcollectionName.toString());
    DocumentReference subdocument =
        subcollection.doc(subdocumentName.toString());

    // Upload data to Firestore
    await subdocument.set({
      fieldName: value,
      // Add other fields as needed
    }, SetOptions(merge: true));
  }

  Future<void> uploadList(String collectionName, String documentName,
      String fieldName, List<String> value) async {
    // Reference to Firestore collection, document, subcollection, and subdocument
    CollectionReference collection =
        FirebaseFirestore.instance.collection(collectionName);
    DocumentReference document = collection.doc(documentName);

    await document.set({
      fieldName: FieldValue.arrayUnion(value),
      // Add other fields as needed
    }, SetOptions(merge: true));
  }

  Future<String> _blockNumber(String classroom) async {
    String blockNumber;

    if (classroom.length == 5) {
      blockNumber = classroom.substring(0, 2);
    } else if (classroom.length == 4) {
      blockNumber = classroom.substring(0, 1);
    } else {
      blockNumber = classroom;
    }

    // Return the block number.
    return blockNumber;
  }

  Future<String> _classnumber(String classroom) async {
    String classnumber;

    if (classroom.length == 5) {
      classnumber = classroom.substring(2);
    } else if (classroom.length == 4) {
      classnumber = classroom.substring(1);
    } else {
      classnumber = classroom;
    }

    // Return the block number.
    return classnumber;
  }

  bool allKeysHaveOneValueAndTwoOrMoreKeys() {
    // Check if batchesMap has more than or equal to 2 keys
    if (batchesMap.length >= 2) {
      // Check if all keys have exactly one value
      return batchesMap.values.every((values) => values.length == 1);
    } else {
      // If batchesMap has less than 2 keys, return false
      return false;
    }
  }

  void _splitInto2(List<List<dynamic>> all, List<List<dynamic>> batch1,
      List<List<dynamic>> batch3) {
    int totalRows = all.length;

    if (totalRows % 2 == 0) {
      // If the total number of rows is even, split equally
      int halfRows = totalRows ~/ 2;
      batch1.addAll(all.sublist(0, halfRows));
      batch3.addAll(all.sublist(halfRows));
    } else {
      // If the total number of rows is odd, split equally and add the left one to batch3
      int halfRows = (totalRows + 1) ~/ 2;
      batch1.addAll(all.sublist(0, halfRows - 1));
      batch3.addAll(all.sublist(halfRows - 1));
    }
  }

  void _splitInto3(List<List<dynamic>> all, List<List<dynamic>> batch1,
      List<List<dynamic>> batch2, List<List<dynamic>> batch3) {
    int totalRows = all.length;

    if (totalRows % 3 == 0) {
      // If the total number of rows is a multiple of 3, split equally
      int thirdRows = totalRows ~/ 3;
      batch1.addAll(all.sublist(0, thirdRows));
      batch2.addAll(all.sublist(thirdRows, 2 * thirdRows));
      batch3.addAll(all.sublist(2 * thirdRows));
    } else {
      // If the total number of rows is not a multiple of 3, handle accordingly
      int thirdRows = totalRows ~/ 3;
      batch1.addAll(all.sublist(0, thirdRows));
      batch2.addAll(all.sublist(thirdRows, 2 * thirdRows));
      batch3.addAll(all.sublist(2 * thirdRows));
    }
  }

  Future<List<List<dynamic>>> readCsv(File file) async {
    try {
      List<List<dynamic>> csvList =
          CsvToListConverter().convert(await file.readAsString());

      // Assuming the first row contains headers, you can print them
      print('Headers: ${csvList[0]}');

      // Iterate over the rows and print data
      for (int i = 1; i < csvList.length; i++) {
        print('Row $i: ${csvList[i]}');
      }

      return csvList;
    } catch (e) {
      print('Error reading CSV file: $e');
      return [];
    }
  }

  void _handleSeatingButtonClick(String seat) {
    setState(() {
      if (!_isSeatAlreadyAdded(seat)) {
        batchesMap[selectedBatch]!.add(seat);
      }
    });
  }

  bool _isSeatAlreadyAdded(String seat) {
    return batchesMap.values.any((seats) => seats.contains(seat));
  }

  void _handleOkButtonClick(String batch) {
    setState(() {
      if (batchesMap[selectedBatch]!.isNotEmpty &&
          batchesMap[selectedBatch]!.length < 3) {
        batchesMap['Batch ${batchesMap.length + 1}'] = [];
        selectedBatch = 'Batch ${batchesMap.length}';
      }
    });
  }

  void _removeEmptyBatches() {
    batchesMap.removeWhere((batch, seats) => seats.isEmpty);
  }

  void _updateFirestore() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create or get the reference to the document
      DocumentReference documentRef =
          firestore.collection('SOC_FILES').doc(widget.documentname);

      // Update the document with batchesMap
      await documentRef.set(batchesMap);

      print('Firestore updated successfully!');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  void _createBatchWidgets() {
    // Create a new map with the same data as batchesMap
    Map<String, List<String>> batchMap1 = Map.from(batchesMap);

    if (batchesMap.isNotEmpty) {
      // Add two additional entries to batchMap1
      batchMap1['HallNumbers'] = [];
      batchMap1['LecturerNames'] = [];

      batchWidgets = batchMap1.keys.map((batch) {
        return Row(
          key: Key(batch), // Add a unique key for each Row
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '$batch: ${batchMap1[batch]!.join(', ')}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: FileUploadButton(
                documentName: widget.documentname,
                batchNumber: batch,
                uploadedFiles: uploadedFiles,
              ),
            ),
          ],
        );
      }).toList();
    } else {
      batchWidgets = [
        Text('No batches available.'),
        // You can add more widgets or customize the message based on your requirements.
      ];
    }

    setState(() {});
  }

  void createFileWidget() {
    FileWidgets = uploadedFiles.keys.map((String key) {
      File file = uploadedFiles[key]!;
      String fileName = file.path.split("/").last;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                fileName,
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                csvRead(file);
              },
              icon: Icon(Icons.shuffle),
              label: Text('Randomize'),
            ),
          ),
        ],
      );
    }).toList();
    // Call setState to trigger a rebuild with the updated FileWidgets
    setState(() {});
  }

  Future<void> csvRead(File file) async {
    // Specify the path to your CSV file
    String csvFilePath = file.path;

    // Read the CSV file as a String
    String csvContent = await File(csvFilePath).readAsString();

    // Parse the CSV content
    List<List<dynamic>> csvList = CsvToListConverter().convert(csvContent);

    // Shuffle the rows
    csvList.shuffle();

    // Encode the randomized CSV data
    String randomizedCsvContent = ListToCsvConverter().convert(csvList);
    await File(csvFilePath).writeAsString(randomizedCsvContent);
  }

  void _uploadFilesToStorage() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Set to false to prevent dismissing
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text("Uploading files please wait..."),
              ],
            ),
          );
        },
      );

      final storageRef = FirebaseStorage.instance.ref();

      for (MapEntry<String, File> entry in uploadedFiles.entries) {
        String batch = entry.key;
        File file = entry.value;
        String fileName = file.path.split("/").last;

        print("Uploading file for batch: $batch");

        final uploadTask = storageRef
            .child("SOC_FILES/${widget.documentname}/$fileName")
            .putFile(file);
        // Wait for the upload to complete and get the download URL
        final TaskSnapshot taskSnapshot = await uploadTask;
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();

        uploadedFilesLinks[batch] = downloadURL;
      }

      _uploadFileLinksToFirestore();
      createFileWidget();

      // Close loading dialog
      Navigator.of(context).pop();

      print("All files uploaded successfully!");
    } catch (e) {
      print("Error uploading files to Firebase Storage: $e");
      // Close loading dialog in case of an error
      Navigator.of(context).pop();
    }
  }

  void _uploadFileLinksToFirestore() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      for (MapEntry<String, String> entry in uploadedFilesLinks.entries) {
        String batch = entry.key;
        String downloadURL = entry.value;

        // Create or get the reference to the document
        DocumentReference documentRef =
            firestore.collection('SOC_FILES').doc(widget.documentname);

        // Update the document with the download URL
        await documentRef.set({
          'links_$batch': downloadURL,
        }, SetOptions(merge: true));

        print(
            'Firestore updated successfully for batch $batch with link: $downloadURL');
      }

      print('All links uploaded to Firestore successfully!');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  void fetchDataFromFirestore() async {
    try {
      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        // Show loading dialog
        _isLoading = true;
      });

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot documentSnapshot = await firestore
          .collection('SOC_FILES')
          .doc(widget.documentname)
          .get();

      if (!mounted) return; // Check again if the widget is still mounted

      Map<String, dynamic> firestoreData =
          (documentSnapshot.data() as Map<String, dynamic>) ?? {};

      Map<String, List<String>> newBatchesMap = {};
      Map<String, String> newUploadedFilesLinks = {};

      firestoreData.forEach((key, value) {
        if (key.startsWith('Batch')) {
          newBatchesMap[key] = List<String>.from(value);
        } else if (key.startsWith('links_')) {
          String batchKey = key.replaceFirst('links_', '');
          newUploadedFilesLinks[batchKey] = value.toString();
        }
      });

      // Update the state variables
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading dialog
        });

        if (newBatchesMap.isNotEmpty) {
          batchesMap = newBatchesMap;
        }

        if (newUploadedFilesLinks.isNotEmpty) {
          uploadedFilesLinks = newUploadedFilesLinks;
        }

        for (var entry in uploadedFilesLinks.entries) {
          File? file = await downloadFile(entry.value);
          if (file != null) {
            uploadedFiles[entry.key] = file;
            isArrangeVisible = true;
          } else {
            // Failed to download the file.
          }
        }

        bool blocks = await hasData("SOC_FILES", widget.documentname, "blocks");
        if (blocks) {
          isReportVisible = true;
          print("The document has blocks.");
        } else {
          isReportVisible = false;
          print("The document does not have blocks.");
        }

        createFileWidget();
        print("UPloded files: $uploadedFiles");
        print('Data retrieved successfully:');
        print('Batches Map: $batchesMap');
        print('Uploaded Files Links Map: $uploadedFilesLinks');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading dialog
        });
      }
      print('Error fetching data from Firestore: $e');
    }
  }

  Future<bool> hasData(
      String collectionname, String documetname, String fieldname) async {
    try {
      // Get a reference to the document
      DocumentReference<Map<String, dynamic>> document = FirebaseFirestore
          .instance
          .collection(collectionname)
          .doc(documetname);

      // Get the document snapshot
      DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();

      if (snapshot.exists) {
        // Check if the specified field is present and not null
        if (snapshot.data() != null && snapshot.data()![fieldname] != null) {
          // Field is present with values
          return true;
        } else {
          // Field is either not present or has null values
          return false;
        }
      } else {
        // Document does not exist
        return false;
      }
    } catch (error) {
      print("Error checking for data presence: $error");
      return false; // Assume false in case of an error
    }
  }

  String extractFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String decodedPath = uri.pathSegments.map(Uri.decodeComponent).join('/');
    return decodedPath.split('/').last;
  }

  Future<File?> downloadFile(String url) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final directory = await getApplicationSupportDirectory();
        final parentDirectoryPath = '${directory.path}';
        final subdirectoryPath = '$parentDirectoryPath/${widget.documentname}';
        final filePath = '$subdirectoryPath/${extractFileNameFromUrl(url)}';

        // Ensure that the parent directory exists
        final parentDirectoryExists =
            await Directory(parentDirectoryPath).exists();
        if (!parentDirectoryExists) {
          await Directory(parentDirectoryPath).create(recursive: true);
        }

        // Ensure that the subdirectory exists
        final subdirectoryExists = await Directory(subdirectoryPath).exists();
        if (!subdirectoryExists) {
          await Directory(subdirectoryPath).create(recursive: true);
        }

        await File(filePath).writeAsBytes(response.bodyBytes);
        print("FilepathStore: $filePath");
        return File(filePath);
      } else {
        print(
            'Failed to download file. HTTP Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading file: $e');
      // You might want to handle errors more gracefully here
      return null;
    }
  }
}

class FileUploadButton extends StatelessWidget {
  final String batchNumber;
  final String documentName; // Add this line to receive the document name
  final Map<String, File> uploadedFiles;
  // Constructor to initialize the documentName
  const FileUploadButton(
      {required this.documentName,
      required this.batchNumber,
      required this.uploadedFiles});

  Future<void> _handleFileUpload() async {
    // Remove underscore to make it public
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );

    if (result != null) {
      PlatformFile? pickedFile = result.files.single;
      String fileName = result.files.first.name;
      File file = File(pickedFile!.path!);

      await _saveFileInternally(documentName, fileName, file);
      uploadedFiles[batchNumber] = file;
      print("uploadedFiles: $uploadedFiles");

      print("FileName: $fileName");
      print("file: ${file.path}");
      String filename = file.path.split("/").last;
      print("filename: ${filename}");
    }
  }

  Future<void> _saveFileInternally(
      String documentName, String fileName, File file) async {
    try {
      final directory = await getApplicationSupportDirectory();
      final documentDirectory = Directory('${directory.path}/$documentName');

      // Check if the subfolder exists, create it if not
      if (!documentDirectory.existsSync()) {
        documentDirectory.createSync();
      }

      final filePath = '${documentDirectory.path}/$fileName';

      // Copy the file to the internal storage
      await file.copy(filePath);

      print("File saved internally: $filePath");
    } catch (e) {
      print("Error saving file internally: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _handleFileUpload,
      icon: Icon(Icons.upload_file),
      label: Text('Upload File'),
    );
  }
}

class ProgressDialog extends StatefulWidget {
  final double progress;

  ProgressDialog({Key? key, required this.progress}) : super(key: key);

  @override
  ProgressDialogState createState() => ProgressDialogState();

  // Function to update progress from outside the widget
  void updateProgress(double newProgress) {
    (key as GlobalKey<ProgressDialogState>)
        .currentState
        ?.updateProgress(newProgress);
  }
}

class ProgressDialogState extends State<ProgressDialog> {
  double _progress = 0.0;

  // Function to update progress within the widget
  void updateProgress(double newProgress) {
    setState(() {
      _progress = newProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Uploading to Firestore'),
          SizedBox(height: 16),
          LinearProgressIndicator(value: _progress),
          SizedBox(height: 16),
          Text('${(_progress * 100).toStringAsFixed(2)}% Completed'),
        ],
      ),
    );
  }
}
