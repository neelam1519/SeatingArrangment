import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'PdfGenerator.dart';

Future<void> saveAndLaunch(
    List<int> bytes, String documentName, String filename) async {
  final directory = await getApplicationSupportDirectory();
  final parentDirectoryPath =
      '${directory.path}/$documentName'; // Updated this line

  File file = File('$parentDirectoryPath/$filename');
  await file.writeAsBytes(bytes, flush: true);
  OpenFile.open('$parentDirectoryPath/$filename');
}

Future<void> StringGenerator(PdfDocument document, PdfPage page, String date,
    String time, String sessional) async {
  // Add a new page
  PdfStringFormat format = PdfStringFormat(
    alignment: PdfTextAlignment.center,
    lineAlignment: PdfVerticalAlignment.middle,
  );

  // Define your multi-line string
  String multilineText = '''
    KALASALINGAM ACADEMY OF RESEARCH AND EDUCATION
    (Deemed to be University)
    Anand Nagar, Krishnankoil - 626 126
    School of Computing
    ATTENDANCE SHEET
    $sessional - EVEN SEMESTER $date-$time
  ''';

  PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 10);
  double pageWidth = page.getClientSize().width;

  page.graphics.drawString(
    multilineText,
    font,
    format: format,
    brush: PdfSolidBrush(PdfColor(0, 0, 0)),
    bounds: Rect.fromLTWH(100, 0, font.measureString(multilineText).width,
        font.measureString(multilineText).height),
  );

  // Call CreateTables to draw tables on the same page
  await CreateTables(page);
}

Future<void> CreateTables(PdfPage page) async {
  PdfGrid pdfGrid = PdfGrid();
  pdfGrid.columns.add(count: 8);
  pdfGrid.headers.add(1);

  PdfGridRow header = pdfGrid.headers[0];
  header.cells[0].value = "S.No";
  header.cells[1].value = "Regno";
  header.cells[2].value = "Name";
  header.cells[3].value = "Sec";
  header.cells[4].value = "Staff ID";
  header.cells[5].value = "Course Code";
  header.cells[6].value = "Answer Sheet No";
  header.cells[7].value = "Signature";

  // Customize column widths
  pdfGrid.columns[0].width = 20;
  pdfGrid.columns[1].width = 60;
  pdfGrid.columns[2].width = 120;
  pdfGrid.columns[3].width = 25;
  pdfGrid.columns[4].width = 80;
  pdfGrid.columns[5].width = 55;
  pdfGrid.columns[6].width = 50;
  pdfGrid.columns[7].width = 70;

  // Add row values
  PdfGridRow row1 = pdfGrid.rows.add();
  row1.cells[0].value = "1";
  row1.cells[1].value = "99210041602";
  row1.cells[2].value = "Neelam Madhusudhan Reddy";
  row1.cells[3].value = "S25";
  row1.cells[4].value = "Mr.V.Anushyadevi";
  row1.cells[5].value = "212CSE2301";
  row1.cells[6].value = "1234567890";
  row1.cells[7].value = "STUDENTSIGNATURE";

  // Adjust the Y-coordinate to position the table below the multiline text
  pdfGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 80, page.getClientSize().width, 100));
}
