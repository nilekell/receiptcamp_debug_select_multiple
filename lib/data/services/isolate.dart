import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:path/path.dart' hide Style;
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/services/directory_path_provider.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:archive/archive_io.dart';

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
    await DirectoryPathProvider.instance.initialize();

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

  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  final Style headingStyle = workbook.styles.add('HeadingStyle');
  headingStyle.bold = true;
  headingStyle.hAlign = HAlignType.center;

  sheet.getRangeByName('A1').setText('Name');
  sheet.getRangeByName('A1').cellStyle = headingStyle;
  sheet.getRangeByName('B1').setText('Price');
  sheet.getRangeByName('B1').cellStyle = headingStyle;
  sheet.getRangeByName('C1').setText('Date Created');
  sheet.getRangeByName('C1').cellStyle = headingStyle;
  sheet.getRangeByName('D1').setText('Folder Name');
  sheet.getRangeByName('D1').cellStyle = headingStyle;
  sheet.getRangeByName('E1').setText('File Name');
  sheet.getRangeByName('E1').cellStyle = headingStyle;

  int rowIndex = 2;
  const double columnWidth = 25.0;

  for (final excelReceipt in excelReceipts) {
    sheet.getRangeByName('A$rowIndex').setText(excelReceipt.name);
    sheet.getRangeByName('A$rowIndex').columnWidth = columnWidth;

    sheet.getRangeByName('B$rowIndex').setText(excelReceipt.price);
    sheet.getRangeByName('B$rowIndex').columnWidth = columnWidth;

    sheet.getRangeByName('C$rowIndex').setText(Utility.formatDateTimeFromUnixTimestamp(excelReceipt.dateCreated));
    sheet.getRangeByName('C$rowIndex').columnWidth = columnWidth;

    final folder = await DatabaseRepository.instance.getFolderById(excelReceipt.parentId);
    sheet.getRangeByName('D$rowIndex').setText(folder.name);
    sheet.getRangeByName('D$rowIndex').columnWidth = columnWidth;

    sheet.getRangeByName('E$rowIndex').setText(excelReceipt.fileName);
    sheet.getRangeByName('E$rowIndex').columnWidth = columnWidth;

    rowIndex++;
  }

  int imageStartRow = rowIndex + 5;
  int imageColIndex = 0;

  for (final excelReceipt in excelReceipts) {
    img.Image? receiptImage = decodeImage(File('${DirectoryPathProvider.instance.appDocDirPath}/${excelReceipt.fileName}').readAsBytesSync());

    if (receiptImage != null) {
      final List<int> bytes = File('${DirectoryPathProvider.instance.appDocDirPath}/${excelReceipt.fileName}').readAsBytesSync();
      const int maxCellDimension = 100;
      double aspectRatio = receiptImage.width / receiptImage.height;
      int newWidth, newHeight;

      if (aspectRatio >= 1) {
        newWidth = maxCellDimension;
        newHeight = (maxCellDimension / aspectRatio).floor();
      } else {
        newHeight = maxCellDimension;
        newWidth = (maxCellDimension * aspectRatio).floor();
      }

      if (imageColIndex == 5) {
        imageStartRow += 15; 
        imageColIndex = 0;
      }

      sheet.getRangeByIndex(imageStartRow, imageColIndex + 1).setText(excelReceipt.name);
      final picture = sheet.pictures.addStream(imageStartRow + 1, imageColIndex + 1, bytes);
      
      picture.width = newWidth * 2;
      picture.height = newHeight * 2;

      imageColIndex++;
    }
  }

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();
  String tempXlsxFileFullPath = '${DirectoryPathProvider.instance.tempDirPath}/${folder.name}.xlsx';
  final excelFile = await File(tempXlsxFileFullPath).writeAsBytes(bytes);

  return excelFile;
}

static void archiveEntryFunction(Map<String, dynamic> args) async {
    final IsolateParams isolateParams = args['isolateParams'];
    final SendPort sendPort = args['sendPort'];

    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateParams.rootToken);
    await DirectoryPathProvider.instance.initialize();

    final File archiveZipFile =
        await _createArchiveFile(isolateParams.computeParams);

    sendPort.send(archiveZipFile);
  }

  static Future<File> _createArchiveFile(
      Map<String, dynamic> computeParams) async {
    // Deserialize the compute parameters
    List<Map<String, dynamic>> serializedReceipts =
        computeParams['serializedReceipts'];
    List<Map<String, dynamic>> serializedFolders =
        computeParams['serializedFolders'];

    List<Receipt> allReceipts = serializedReceipts
        .map((receiptMap) => Receipt.fromMap(receiptMap))
        .toList();
    List<Folder> allFolders = serializedFolders
        .map((folderMap) => Folder.fromMap(folderMap))
        .toList();
    List<File> allImages = await FileService.getAllReceiptImages();

    // print('allReceipts.length: ${allReceipts.length}');
    // print('allFolders.length: ${allFolders.length}');
    // print('allImages.length: ${allImages.length}');

    final Archive archive = Archive();

    // adding all receipt image files to zip file
    for (final file in allImages) {
      final bytes = await file.readAsBytes();
      archive.addFile(
          ArchiveFile('Images/${basename(file.path)}', bytes.length, bytes));
      // print('added Images/${basename(file.path)} to archive');
    }

    final String newRootFolderId = Utility.generateUid();

    // adding all receipt json object files to zip file
    for (final receipt in allReceipts) {
      if (receipt.parentId == rootFolderId) {
        Receipt adjustedReceipt = Receipt(
            id: receipt.id,
            name: receipt.name,
            fileName: receipt.fileName,
            dateCreated: receipt.dateCreated,
            lastModified: receipt.lastModified,
            storageSize: receipt.storageSize,
            parentId: newRootFolderId);
        String receiptJson = adjustedReceipt.toJson();
        final bytes = utf8.encode(receiptJson); // Convert JSON string to bytes
        archive.addFile(ArchiveFile(
            'Objects/Receipts/${adjustedReceipt.fileName.split('.').first}.json',
            bytes.length,
            bytes));
        // print('added Objects/Receipts/${adjustedReceipt.fileName.split('.').first}.json to archive');
      } else {
        String receiptJson = receipt.toJson();
        final bytes = utf8.encode(receiptJson); // Convert JSON string to bytes
        archive.addFile(ArchiveFile(
            'Objects/Receipts/${receipt.fileName.split('.').first}.json',
            bytes.length,
            bytes));
        // print('added Objects/Receipts/${receipt.fileName.split('.').first}.json to archive');
      }
    }

    // adding all folder json object files to zip file
    for (final folder in allFolders) {
      if (folder.id == rootFolderId) {
        // changing name and id of root folder
        final Folder rootFolder = Folder(
            id: newRootFolderId,
            name: 'Imported_Expenses',
            lastModified: folder.lastModified,
            parentId: rootFolderId);
        String folderJson = rootFolder.toJson();
        final bytes = utf8.encode(folderJson);
        archive.addFile(ArchiveFile(
            'Objects/Folders/${rootFolder.name}.json', bytes.length, bytes));
        // print('added Objects/Folders/${rootFolder.name}.json to archive');
      } else if (folder.parentId == rootFolderId) {
        // changing parent id of folders whose parent id is rootFolderId, as the folder
        Folder adjustedFolder = Folder(
            id: folder.id,
            name: folder.name,
            lastModified: folder.lastModified,
            parentId: newRootFolderId);
        String folderJson = adjustedFolder.toJson();
        String fixedFolderName =
            Utility.concatenateWithUnderscore(adjustedFolder.name);
        final bytes = utf8.encode(folderJson); // Convert JSON string to bytes
        archive.addFile(ArchiveFile(
            'Objects/Folders/$fixedFolderName.json', bytes.length, bytes));
        // print('added Objects/Folders/$fixedFolderName.json to archive');
      } else {
        String folderJson = folder.toJson();
        String fixedFolderName = Utility.concatenateWithUnderscore(folder.name);
        final bytes = utf8.encode(folderJson); // Convert JSON string to bytes
        archive.addFile(ArchiveFile(
            'Objects/Folders/$fixedFolderName.json', bytes.length, bytes));
        // print('added Objects/Folders/$fixedFolderName.json to archive');
      }
    }

    // Check if there are any files to share
    if (archive.isEmpty) {
      throw Exception('Cannot share archive: No files to share');
    }

    // Create an encoder instance
    final zipEncoder = ZipEncoder();

    // Encode the archive
    final encodedArchive = zipEncoder.encode(archive);

    // Create a temporary path to store the zip file
    final String tempArchivePath = await FileService.tempFilePathGenerator(
        'receiptcamp_archive_${Utility.generateUid().substring(0, 5)}.zip');

    // Create a .zip file from the encoded bytes
    final File archiveFile =
        await File(tempArchivePath).writeAsBytes(encodedArchive!);

    return archiveFile;
  }

  static void zipFileEntryFunction(Map<String, dynamic> args) async {
    final IsolateParams isolateParams = args['isolateParams'];
    final SendPort sendPort = args['sendPort'];

    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateParams.rootToken);
    await DirectoryPathProvider.instance.initialize();

    final File resultFile = await _createZipFileFromFolder(isolateParams.computeParams);

    sendPort.send(resultFile);
  }

  static FutureOr<File> _createZipFileFromFolder(Map<String, dynamic> computeParams) async {
    final bool withPdfs = computeParams['withPdfs'];
    final Map<String, dynamic> serializedFolder = computeParams['folder'];
    final Folder folder = Folder.fromMap(serializedFolder);

    // creates an archive instance to store the zip file contents
    final archive = Archive();

    // This function is designed to recursively add files and folders to a ZIP archive.
    // The 'path' parameter serves to keep track of the directory structure as the function recursively processes nested folders
    // It ensures files and folders within the ZIP archive maintain their relative paths, reflecting the original directory structure.
    // the withPdfs paramater is used to determine whether the zip folder will contains all receipt images converted to pdf or not
    Future<void> processFolder(Folder folder, bool withPdfs, [String? path]) async {
      final contents =
          await DatabaseRepository.instance.getFolderContents(folder.id);

      // Allowing empty subfolders to be shown in the unzipped folder
      // Check if the folder is empty and a path is provided (i.e., it's not the root folder)
      if (contents.isEmpty && path != null) {
        // Add a directory entry to the archive
        String fixedFolderPath = Utility.concatenateWithUnderscore(path);
        final directoryPath = '$fixedFolderPath/'; // Ensured it ends with a '/'
        // Instead of passing an empty list as content, we pass a list with a single byte (which is ignored for directories)
        final directoryEntry = ArchiveFile(directoryPath, 0, [0]);
        archive.addFile(directoryEntry);
      }

      for (var item in contents) {
        if (item is Receipt) {
          // initialising en empty XFile
          XFile file = XFile.fromData(Uint8List(0));
          if (withPdfs == true) {
            // converting receipt image file to pdf
            final pdfImage = await FileService.receiptToPdf(item);
            // constructing XFile from pdf
            file = XFile(pdfImage.path);
          } else {
            // just constructing XFile from receipt image file
            file = XFile(item.localPath);
          }
          // read receipt image file as bytes
          final bytes = await File(file.path).readAsBytes();
          // Determine the path for the archive. If a path is provided, prepend it to the file name.
          // This is where the ternary operator is used: it checks if 'path' is not null, and if so,
          // it uses the provided path and appends the file name. Otherwise, it just uses the file name.
          String archivePath;
          String fixedFolderPath;
          if (path != null) {
            fixedFolderPath = Utility.concatenateWithUnderscore(path);
            archivePath = '$fixedFolderPath/${file.name}';
          } else {
            archivePath = file.name;
          }
          // Create an archive file instance with the determined path, file size, and file bytes.
          final archiveFile = ArchiveFile(archivePath, bytes.length, bytes);
          // Add the archive file to the main archive.
          archive.addFile(archiveFile);

          // original files are not deleted as their path references the file stored in application documents directory
          // deleting pdf file from temporary app storage once it as added to zip file archive
          if (withPdfs == true) {
            await File(file.path).delete();
          }
          // for loop goes to next receipt or folder in current directory
        } else if (item is Folder) {
          // Determine the path for the sub-folder. If a path is provided, prepend it to the folder name.
          // Again, the ternary operator is used here to decide the new path.
          final newPath = path != null ? '$path/${item.name}' : item.name;

          // Recursively call the 'processFolder' function to process the contents of the sub-folder.
          // This is the recursive part of the function, allowing it to handle nested folders.
          await processFolder(item, withPdfs, newPath);
        }
      }
    }

    // Start the process by calling the 'processFolder' function with the root folder.
    await processFolder(folder, withPdfs);

    // Check if there are any files to share
    if (archive.isEmpty) {
      throw Exception('Cannot share archive: No files to share in this folder');
    }

    // create an encoder instance
    final zipEncoder = ZipEncoder();

    // encode archive
    final encodedArchive = zipEncoder.encode(archive);

    // create temporary path to store zip file
    final String fixedFolderName = Utility.concatenateWithUnderscore(folder.name); 
    String tempZipFileFullPath = '${DirectoryPathProvider.instance.appDocDirPath}/$fixedFolderName.zip';

    // create a .zip file from the encoded bytes
    final zipFile =
        await File(tempZipFileFullPath).writeAsBytes(encodedArchive!);

    return zipFile;
  }
}
