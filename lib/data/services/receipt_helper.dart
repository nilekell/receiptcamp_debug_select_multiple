import 'dart:io';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/text_recognition.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';

class ReceiptService {
  // getting singleton db repository instance
  static final DatabaseRepository databaseRepository = DatabaseRepository.instance;

  static Future<void> generateAndSaveTags(List<String> keywords, String receiptId) async {
    try {
      for (var keyword in keywords) {
        String tagId = Utility.generateUid();
        Tag tag = Tag(id: tagId, receiptId: receiptId, tag: keyword);
        await databaseRepository.insertTag(tag);
      }
    } on Exception catch (e) {
      print('Error in generateAndSaveTags: $e');
    }
  }

  static Future<bool> generateAndSaveReceipt(String imagePath) async {
    // imagePath is the path to the temporary file of the image
    // stored in cache after the image was taken

    // creating a file object for original quality image
    File originalImageFile = File(imagePath);

    // Getting path to a directory in local storage where compressed image will be saved
    final localImagePath = await FileService.getLocalImagePath();

    // compressing and saving image file to application documents directory
    final compressedFile =
        await FileService.compressFile(originalImageFile, localImagePath);
    if (compressedFile == null) {
      return false;
    }

    final compressedFileName = FileService.getFileNameFromFile(compressedFile);

    // getting original and compressed file sizes
    final originalfileSize =
        await FileService.getFileSize(originalImageFile.path, 2);
    print(originalfileSize);
    final compressedfileSize =
        await FileService.getFileSize(compressedFile.path, 2);
    print(compressedfileSize);

    // Generating receipt object properties

    // Generating new uuid for receipt in local db
    final String myReceiptUid = Utility.generateUid();
    // Getting current time for image creation
    final currentTime = Utility.getCurrentTime();

    // Creating receipt object to be stored in local db
    Receipt thisReceipt = Receipt(
        id: myReceiptUid,
        name: compressedFileName,
        localPath: localImagePath,
        dateCreated: currentTime,
        lastModified: currentTime,
        storageSize: compressedfileSize,
        // id of default folder
        parentId: 'a1');

    // Saving receipt object to database
    try {
      databaseRepository.insertReceipt(thisReceipt);
      print('Image saved at $localImagePath');
    } on Exception catch (e) {
      print('Error in databaseRepository.insertReceipt: $e');
      return false;
    }

    final receiptKeyWords = await TextRecognitionService().extractKeywordsFromImage(imagePath);

    // generating tag object properties and saving to db
    try {
      await generateAndSaveTags(receiptKeyWords, myReceiptUid);
    } on Exception catch (e) {
      print('Error in generateAndSaveTags: $e');
      return false;
    }

    // deleting original quality image file
    try {
      await FileService.deleteImageFromPath(imagePath);
    } on Exception catch (e) {
      print('Error in FileService.deleteImageFromPath: $e');
      return false;
    }

    return true;
  }

  // method to check file name is valid
  static bool validReceiptFileName(String name) {
    // this regex pattern assumes that the file name should consist of only alphabetic characters
    // (lowercase or uppercase), digits, underscores, hyphens, and a file extension consisting of alphabetic
    // characters and digits
    try {
      final RegExp regex = RegExp(r'^[a-zA-Z0-9_\-]+\.[a-zA-Z0-9]+$');
      return name.isNotEmpty && regex.hasMatch(name);
    } on Exception catch (e) {
      print('Error in validReceiptFileName: $e');
      return false;
    }
  }
}
