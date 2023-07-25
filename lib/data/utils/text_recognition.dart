import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  static List<String> _commonReceiptWords = [];

  Future<List<String>> extractKeywordsFromPath(String imagePath) async {
    try {
      final scannedTextList = await _scanImageForText(imagePath);
      final receiptKeyWords = await _extractKeywords(scannedTextList);

      return receiptKeyWords;
    } on Exception catch (e) {
      print('Error in extractKeywordsFromImage: $e');
      return [];
    }
  }

  static Future<List> _scanImageForText(String imagePath) async {
    // Uses Google ML Kit Vision
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
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
    } on Exception catch (e) {
      print('Error in scanImageForText: $e');
      return [];
    }
  }

  Future<List<String>> _extractKeywords(List scannedOCRText) async {
    try {
      String scannedOCRTextList = scannedOCRText.join(' ');
      // Define the regular expression pattern for word characters.
      final pattern = RegExp(r'\w+');
      // Use the pattern to match all the words in the text.
      final matches = pattern.allMatches(scannedOCRTextList);
      // Convert the matches to a list of strings.
      final words = matches.map((match) => match.group(0)!).toList();
      // Use the _commonReceiptWords list as stop words.
      await _loadCommonReceiptWords();
      // Filter out any stop words and return the remaining words.
      final keywords = words
          .where((word) => !_commonReceiptWords.contains(word.toLowerCase()))
          .toSet() // Convert list to set to remove duplicates
          .toList(); // Convert set back to list
      return keywords;
    } on Exception catch (e) {
      print('Error in extractKeywords: $e');
      return [];
    }
  }

  static Future<void> _loadCommonReceiptWords() async {
    try {
      if (_commonReceiptWords.isEmpty) {
        String content =
            await rootBundle.loadString('assets/common_receipt_words.txt');
        _commonReceiptWords =
            content.split('\n').map((word) => word.trim()).toList();
      }
    } on Exception catch (e) {
      print('Error in _loadCommonReceiptWords: $e');
    }
  }
}
