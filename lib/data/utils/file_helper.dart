import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:share_plus/share_plus.dart';

class FileService {
  static Future<File?> compressFile(File imageFile, String targetPath) async {
    CompressFormat format;
    final fileExtension = extension(imageFile.path);

    // final sizeBeforeCompression = await bytesToSizeString(await getFileSize(imageFile.path, 2));
    // print('file size before compression: $sizeBeforeCompression');

    // print('${basename(imageFile.path)} has extension $fileExtension');

    // ImagePicker library automatically converts all images to .jpg, so all uploaded into app via camera or library will have
    // .jpg ending 
    // cunning_document_scanner library produces '.png' files
    // '.heic' case is redundant, but kept in codebase for future proofing
    switch (fileExtension) {
      case '.jpeg':
        format = CompressFormat.jpeg;
        break;
      case '.jpg':
        format = CompressFormat.jpeg;
        break;
      case '.png':
        format = CompressFormat.png;
        break;
      case '.heic': 
        format = CompressFormat.heic;
        break;
      default:
        throw Exception(
            'Exception occurred in FileService.compressFile(): Cannot compress file type: $fileExtension');
    }
 
    try {
      // for some reason, this method actually slightly increases file size for png images
      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        // for jpg/jpeg files only:
        // quality: 88 -> reduced in size by ~50%
        // quality: 1 -> reduced in size by ~95%
        // quality: 30 -> reduced in size by ~95%
        // quality: 50 -> reduced in size by ~87%
        quality: 50,
        format: format,
      );
      if (result == null) {
        return null;
      } else {
        // final sizeAfterCompression = await bytesToSizeString(await getFileSize(result.path, 2));
        // print('file size after compression: $sizeAfterCompression');
        // print('filename after compression ${basename(result.path)}');
        return File(result.path);
      }
    } on Exception catch (e) {
      print('Error in FlutterImageCompress.compressAndGetFile(): $e');
      return null;
    }
  }

  static Future<void> deleteFileFromPath(String imagePath) async {
    try {
      File originalImageFile = File(imagePath);

      // deleting original quality image file
      if (await originalImageFile.exists()) {
        originalImageFile.delete();
        print('File deleted: $imagePath');
      } else {
        print('File does not exist: $imagePath');
      }
    } on Exception catch (e) {
      print('Error in deleteFileFromPath: $e');
    }
  }

  static Future<String> getLocalImagePath(ImageFileType imageFileType) async {
    try {
      Directory imageDirectory = await getApplicationDocumentsDirectory();
      String imageDirectoryPath = imageDirectory.path;
      final fileName = Utility.generateFileName(imageFileType);
      final localImagePath = '$imageDirectoryPath/$fileName';

      return localImagePath;
    } on Exception catch (e) {
      print('Error in getLocalImagePath: $e');
      return '';
    }
  }

  static Future<int> getFileSize(String filepath, int decimals) async {
    try {
      var file = File(filepath);
      int bytes = await file.length();
      return bytes;
    } on Exception catch (e) {
      print('Error in getFileSize: $e');
      return -1;
    }
  }

  static Future<Uint8List> pathToUint8List(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final bytesList = Uint8List.fromList(bytes);
      return bytesList;
    } on Exception catch (e) {
      print('Error in pathToUint8List: $e');
      return Uint8List(0);
    }
  }

  static String getFileNameFromFile(File file) {
    try {
      final fileName = basename(file.path);
      return fileName;
    } on Exception catch (e) {
      print('Error in getFileNameFromFile: $e');
      return '';
    }
  }

  // convert bytes to string that represents file sizes
  static Future<String> bytesToSizeString(int bytes) async {
    try {
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB"];
      var i = (log(bytes) / log(1024)).floor();
      return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
    } on Exception catch (e) {
      print('Error in bytesToSizeString: $e');
      return '';
    }
  }

  // share receipt image
  static Future<void> shareReceipt(Receipt receipt) async {
    try {
      // shows platform share sheet
      await Share.shareXFiles([XFile(receipt.localPath)],
          subject: receipt.name);
    } on Exception catch (e) {
      print('Error in shareReceipt: $e');
      return;
    }
  }

  // share folder outside of app
  static Future<void> shareFolderAsZip(Folder folder) async {
    // creates an archive instance to store the zip file contents
    final archive = Archive();

    // This function is designed to recursively add files and folders to a ZIP archive.
    // The 'path' parameter serves to keep track of the directory structure as the function recursively processes nested folders
    // It ensures files and folders within the ZIP archive maintain their relative paths, reflecting the original directory structure.
    Future<void> processFolder(Folder folder, [String? path]) async {
      final contents = await DatabaseRepository.instance.getFolderContents(folder.id);

      // Allowing empty subfolders to be shown in the unzipped folder
      // Check if the folder is empty and a path is provided (i.e., it's not the root folder)
      if (contents.isEmpty && path != null) {
        // Add a directory entry to the archive
        final directoryPath = '$path/';  // Ensured it ends with a '/'
        // Instead of passing an empty list as content, we pass a list with a single byte (which is ignored for directories)
        final directoryEntry = ArchiveFile(directoryPath, 0, [0]);
        archive.addFile(directoryEntry);
      }


      for (var item in contents) {
        if (item is Receipt) {
          final file = XFile(item.localPath);
          // read receipt image file as bytes
          final bytes = await File(file.path).readAsBytes();
          // Determine the path for the archive. If a path is provided, prepend it to the file name.
          // This is where the ternary operator is used: it checks if 'path' is not null, and if so, 
          // it uses the provided path and appends the file name. Otherwise, it just uses the file name.
          final archivePath = path != null ? '$path/${file.name}' : file.name;
          // Create an archive file instance with the determined path, file size, and file bytes.
          final archiveFile = ArchiveFile(archivePath, bytes.length, bytes);
          // Add the archive file to the main archive.
          archive.addFile(archiveFile);
          // for loop goes to next receipt or folder in current directory
        } else if (item is Folder) {
          // Determine the path for the sub-folder. If a path is provided, prepend it to the folder name.
          // Again, the ternary operator is used here to decide the new path.
          final newPath = path != null ? '$path/${item.name}' : item.name;

          // Recursively call the 'processFolder' function to process the contents of the sub-folder.
          // This is the recursive part of the function, allowing it to handle nested folders.
          await processFolder(item, newPath);
        }
      }
    }

    // Start the process by calling the 'processFolder' function with the root folder.
    await processFolder(folder);

    // Check if there are any files to share
    if (archive.isEmpty) {
      print("No files to share in this folder.");
      return;
    }

    // create an encoder instance
    final zipEncoder = ZipEncoder();

    // encode archive
    final encodedArchive = zipEncoder.encode(archive);
    if (encodedArchive == null) {
      print('empty encoded archive');
      return;
    }

    // create temporary path to store zip file
    String tempZipFileFullPath = await tempZipFilePathGenerator(folder);

    // create a .zip file from the encoded bytes
    final zipFile = await File(tempZipFileFullPath).writeAsBytes(encodedArchive);

    // Share the zip file
    await Share.shareXFiles([XFile(zipFile.path)]);

    // delete zip file from local temp directory
    await FileService.deleteFileFromPath(zipFile.path);
}

  static Future<String> tempZipFilePathGenerator(Folder folder) async {
    final zipFileName = '${folder.name}.zip';
    final tempZipFileDirectory = await getTemporaryDirectory();
    final tempZipFilePath = tempZipFileDirectory.path;
    final tempZipFileFullPath = '$tempZipFilePath/$zipFileName';
    return tempZipFileFullPath;
  }

  // download image to camera roll
  static Future<void> saveImageToCameraRoll(Receipt receipt) async {
    try {
      await GallerySaver.saveImage(receipt.localPath);
      print('image saved to camera roll');
    } on Exception catch (e) {
      print('Error in saveImageToCameraRoll: $e');
      rethrow;
    }
  }
}
