import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class IsolateParams {
  final Map<String, dynamic> computeParams;
  final RootIsolateToken rootToken;

  IsolateParams({
    required this.computeParams,
    required this.rootToken,
  });
}

abstract class IsolateService {
  
  static void excelEntryFunction(Map<String, dynamic> args) async {
    final IsolateParams isolateParams = args['isolateParams'];
    final SendPort sendPort = args['sendPort'];

    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateParams.rootToken);

    final File resultFile =
        await _createExcelSheetfromReceipts(isolateParams.computeParams);

    sendPort.send(resultFile);
  }

  static FutureOr<File> _createExcelSheetfromReceipts(
      Map<String, dynamic> computeParams) async {
    final List<Map<String, dynamic>> serializedReceipts =
        computeParams['excelReceipts'];
    final Map<String, dynamic> serializedFolder = computeParams['folder'];

    final List<ExcelReceipt> excelReceipts =
        serializedReceipts.map((e) => ExcelReceipt.fromMap(e)).toList();
    final Folder folder = Folder.fromMap(serializedFolder);

    // Create a new Excel document.
    final Workbook workbook = Workbook();

    // Accessing worksheet via index.
    final Worksheet sheet = workbook.worksheets[0];

    // Create column titles
    sheet.getRangeByName('A1').setText('Name');
    sheet.getRangeByName('B1').setText('Price');
    sheet.getRangeByName('C1').setText('Date Created');
    sheet.getRangeByName('D1').setText('Image');
    sheet.getRangeByName('E1').setText('Parent Name');
    sheet.getRangeByName('F1').setText('File Name');

    // Starting index for data
    int rowIndex = 2;

    const double columnWidth = 25.0;

    for (final excelReceipt in excelReceipts) {
      // Insert data into rows
      final nameColumn = sheet.getRangeByName('A$rowIndex');
      nameColumn.setText(excelReceipt.name);
      nameColumn.columnWidth = columnWidth;

      final priceColumn = sheet.getRangeByName('B$rowIndex');
      priceColumn.setText(excelReceipt.price);
      priceColumn.columnWidth = columnWidth;

      final dateColumn = sheet.getRangeByName('C$rowIndex');
      dateColumn.setText(
          Utility.formatDateTimeFromUnixTimestamp(excelReceipt.dateCreated));
      dateColumn.columnWidth = columnWidth;

      // Load the image using the 'image' package.

      final String appDocDirPath =
          (await getApplicationDocumentsDirectory()).path;

      img.Image? receiptImage = decodeImage(
          File('$appDocDirPath/${excelReceipt.fileName}').readAsBytesSync());

      //Adding a picture
      final List<int> bytes =
          File('$appDocDirPath/${excelReceipt.fileName}').readAsBytesSync();
      if (receiptImage != null) {
        final picture = sheet.pictures.addStream(rowIndex, 4, bytes);

        const int maxCellDimension =
            100; // Maximum dimension for either width or height

        double aspectRatio = receiptImage.width / receiptImage.height;

        int newWidth, newHeight;

        if (aspectRatio >= 1) {
          // Width is greater than height
          newWidth = maxCellDimension;
          newHeight = (maxCellDimension / aspectRatio).floor();
        } else {
          // Height is greater than width
          newHeight = maxCellDimension;
          newWidth = (maxCellDimension * aspectRatio).floor();
        }

        picture.width = newWidth;
        picture.height = newHeight;

        // Add padding by increasing the column width and row height
        const double padding = 20; // adjust as needed
        sheet.getRangeByName('D$rowIndex').columnWidth = newWidth + padding;
        sheet.getRangeByName('D$rowIndex').rowHeight = newHeight + padding;

        // // Set static row height and column width for the cell.
        // sheet.getRangeByName('D$rowIndex').rowHeight = maxCellDimension.toDouble();
        // sheet.getRangeByName('D$rowIndex').columnWidth = maxCellDimension.toDouble();
      }

      final folderNameColumn = sheet.getRangeByName('E$rowIndex');
      folderNameColumn.setText(excelReceipt.name);
      folderNameColumn.columnWidth = columnWidth;

      final fileNameColumn = sheet.getRangeByName('F$rowIndex');
      fileNameColumn.setText(excelReceipt.fileName);
      fileNameColumn.columnWidth = columnWidth;

      rowIndex++; // Increment the row index for the next iteration
    }

    // Save to the Excel file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // create temporary path to store excel file
    String tempXlsxFileFullPath =
        '${((await getTemporaryDirectory()).path)}/${folder.name}.xlsx';

    // create a .xlsx file from the encoded bytes
    final excelFile = await File(tempXlsxFileFullPath).writeAsBytes(bytes);

    return excelFile;
  }
}
