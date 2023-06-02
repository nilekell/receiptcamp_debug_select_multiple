import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/models/tag.dart';
import 'package:uuid/uuid.dart';

class ReceiptHelper {
  // using DatabaseRepository singleton instance
  final DatabaseRepository databaseRepository = DatabaseRepository.instance;

  static List<String> _commonReceiptWords = [];

  static Future<List<String>> loadCommonReceiptWords() async {
    if (_commonReceiptWords.isEmpty) {
      String content = await rootBundle.loadString('assets/common_receipt_words.txt');
      _commonReceiptWords = content.split('\n').map((word) => word.trim()).toList();
    }
    return _commonReceiptWords;
  }


  static Future<List> scanImageForText(String imagePath) async {
    // Uses Google ML Kit Vision
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String scannedText = recognizedText.text;
    List scannedTextList = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          scannedText = element.text.toLowerCase();
          scannedTextList.add(scannedText);
        }
      }
    }

    return scannedTextList;
  }

  Future<List<String>> extractKeywords(List scannedOCRText) async {
    String scannedOCRTextList = scannedOCRText.join(' ');
    // Define the regular expression pattern for word characters.
    final pattern = RegExp(r'\w+');
    // Use the pattern to match all the words in the text.
    final matches = pattern.allMatches(scannedOCRTextList);
    // Convert the matches to a list of strings.
    final words = matches.map((match) => match.group(0)!).toList();
    // Define a list of common stop words to filter out.
    final stopWords = _commonReceiptWords;
    // Filter out any stop words and return the remaining words.
    final keywords = words.where((word) => !stopWords.contains(word.toLowerCase())).toList();
    return keywords;
  }

  static int getCurrentTime() {
    DateTime dateTimeNow = DateTime.now();
    int unixTimestamp = (dateTimeNow.millisecondsSinceEpoch / 1000).round();
    return unixTimestamp;
  }

  static Future<int> getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    return bytes;
  
}

  static String generateFileName() {
    const Uuid uuid = Uuid();
    final String myUuidString = uuid.v4().toString();
    String fileName = 'RCPT_IMG_$myUuidString.jpg';
    return fileName;
  }

  static String generateUid() {
    // .v4() generates a random uid
    String uid = const Uuid().v4().toString();
    return uid;
  }

  static Future<Uint8List> pathToUint8List(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final bytesList = Uint8List.fromList(bytes);
    return bytesList;
  }


  static Future<bool> compressAndSaveFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 88,
        format: CompressFormat.jpeg
      );

    if (result == null) {
      throw Exception('Failed to compress file');
    } else {
      return true;
    }
  }

  Future<bool> saveImageAndReceipt(String imagePath) async {
    // imagePath is the path to the temporary file of the image
    // stored in cache after the image was taken

    // Getting path to a directory in local storage where image will be saved
    Directory imageDirectory = await getApplicationDocumentsDirectory();
    String imageDirectoryPath = imageDirectory.path;
    final fileName = generateFileName();
    final localImagePath = '$imageDirectoryPath/$fileName';

    // creating a file object for original quality image
    File imageFile = File(imagePath);

    // Getting tags for image from original quality image
    final scannedTextList = await scanImageForText(imagePath);
    final receiptKeyWords = await extractKeywords(scannedTextList);

    // compressing and saving image file to application documents directory
    bool compressAndSaveSuccess = await compressAndSaveFile(imageFile, localImagePath);
    if (compressAndSaveSuccess) {
      print('image sucessfully compressed and locally stored');
    } else {
      print('image failed to be compressed and locally stored');
      return false;
    }

    // getting file size 
    final fileSize = await getFileSize(localImagePath, 2);

    // deleting original quality image file
    if (await imageFile.exists()) {
      imageFile.delete();
      print('File deleted: $imagePath');
    } else {
      print('File does not exist: $imagePath');
    }

    // Generating new uuid for receipt in local db
    final String myReceiptUid = generateUid();

    // Getting current time for image creation
    final currentTime = getCurrentTime();

    // Creating receipt object to be stored in local db
    Receipt thisReceipt = Receipt(
          id: myReceiptUid,
          name: fileName,
          localPath: localImagePath,
          dateCreated: currentTime, 
          lastModified: currentTime, 
          storageSize: fileSize,
          // id of default folder
          parentId: 'a1'
          );

    // Saving receipt object to database
    databaseRepository.insertReceipt(thisReceipt);
    print('Image saved at $localImagePath');

    // iterating over receipt key words list to populate tags table with individual tag objects
    for (int i = 0; i < receiptKeyWords.length; i++) {
      // Generating new uuid for tag in local db
      final String myTagUid = generateUid();
      // creating a tag object to be inserted into tags table
      Tag thisTag = Tag(
      id: myTagUid,
      receiptId: myReceiptUid,
      tag: receiptKeyWords[i]
      );
      // Saving associated receipt tag to database
      databaseRepository.insertTag(thisTag);
    }

    return true;
  }

  // converts unix timestamp to datetime string
  static String formatDateTimeFromUnixTimestamp(int unixTimestamp) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
      String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      return formattedDateTime;
  }

  // converts datetime string to unix timestamp
  static int formatUnixTimeStampFromDateTime(String formattedDateTime) {
    DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedDateTime);
    int unixTimestamp = dateTime.millisecondsSinceEpoch ~/ 1000;
    return unixTimestamp;
  }

  // convert bytes to string that represents file sizes
  static Future<String> bytesToSizeString(int bytes) async {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // method to check file name is valid
  // this regex pattern assumes that the file name should consist of only alphabetic characters 
  // (lowercase or uppercase), digits, underscores, hyphens, and a file extension consisting of alphabetic 
  // characters and digits
  static bool validReceiptFileName(String name) {
  final RegExp regex = RegExp(r'^[a-zA-Z0-9_\-]+\.[a-zA-Z0-9]+$');
  return name.isNotEmpty && regex.hasMatch(name);
  }
}
