import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/data/utils/file_helper.dart';
import 'package:receiptcamp/data/utils/text_recognition.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';

class ReceiptService {
  // getting singleton db repository instance
  static final DatabaseRepository databaseRepository =
      DatabaseRepository.instance;

  static List<Tag> _generateTags(List<String> keywords, String receiptId) {
    List<Tag> tags = [];
    try {
      for (var keyword in keywords) {
        String tagId = Utility.generateUid();
        Tag tag = Tag(id: tagId, receiptId: receiptId, tag: keyword);
        tags.add(tag);
      }
    } on Exception catch (e) {
      print('Error in generateTags: $e');
    }
    return tags;
  }

  // create and return receipt object
  static Future<Receipt> createReceiptFromFile(
      File receiptFile, String fileName, String folderId, String receiptUid) async {
    // Generating receipt object properties

    final path = receiptFile.path;
    // Getting current time for image creation
    final currentTime = Utility.getCurrentTime();

    // getting compressed file sizes
    final compressedfileSize = await FileService.getFileSize(path, 2);

    // Creating receipt object to be stored in local db
    Receipt thisReceipt = Receipt(
        id: receiptUid,
        name: fileName,
        localPath: path,
        dateCreated: currentTime,
        lastModified: currentTime,
        storageSize: compressedfileSize,
        // id of default folder
        parentId: folderId);

    return thisReceipt;
  }
  
  static Future<List<Tag>> extractKeywordsAndGenerateTags(String imagePath, String receiptId) async {
  List<Tag> tags = [];

  try {
    final receiptKeyWords = await TextRecognitionService().extractKeywordsFromPath(imagePath);
    print(receiptKeyWords);
    tags = _generateTags(receiptKeyWords, receiptId);
  } on Exception catch (e) {
    print('Error in extractKeywordsAndGenerateTags: $e');
  }

  return tags;
}

  static Future<List<dynamic>> processingReceiptAndTags(XFile receiptImage, String folderId) async {
  // tag actions
  final receiptUid = Utility.generateUid();
  final tagsList = await ReceiptService.extractKeywordsAndGenerateTags(
      receiptImage.path, receiptUid);

  // compressing and saving image
  final localReceiptImagePath = await FileService.getLocalImagePath();
  final receiptImageFile = await FileService.compressFile(
      File(receiptImage.path), localReceiptImagePath);

  // deleting temporary image files
  await FileService.deleteFileFromPath(receiptImage.path);

  // creating receipt object
  final receipt = await ReceiptService.createReceiptFromFile(
      receiptImageFile!, basename(receiptImageFile.path), folderId, receiptUid);

  return [receipt, tagsList];
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
