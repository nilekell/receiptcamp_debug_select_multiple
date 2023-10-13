import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  static List<String> _commonReceiptWords = [];

  Future<List<String>> extractKeywordsFromPath(String imagePath) async {
    try {
      final scannedTextList = await scanImageForText(imagePath);
      final receiptKeyWords = await extractKeywords(scannedTextList);

      return receiptKeyWords;
    } on Exception catch (e) {
      print('Error in extractKeywordsFromImage: $e');
      return [];
    }
  }

  @visibleForTesting
  static Future<List<String>> scanImageForText(String imagePath) async {
    // Uses Google ML Kit Vision
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      String scannedText = recognizedText.text;
      List<String> scannedTextList = [];
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

  @visibleForTesting
  static Future<List<String>> extractKeywords(List scannedOCRText) async {
    try {
      String scannedOCRTextList = scannedOCRText.join(' ');
      // Define the regular expression pattern for word characters.
      final pattern = RegExp(r'\w+');
      // Use the pattern to match all the words in the text.
      final matches = pattern.allMatches(scannedOCRTextList);
      // Convert the matches to a list of strings.
      final words = matches.map((match) => match.group(0)!).toList();
      // Use the _commonReceiptWords list as stop words.
      await loadCommonReceiptWords();
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

  @visibleForTesting
  static Future<void> loadCommonReceiptWords() async {
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

  static Future<bool> imageHasText(String imagePath) async {
    try {
      final scannedTextList =
          await TextRecognitionService.scanImageForText(imagePath);
      // most if not all receipts will have greater than 10 text elements (space separated words)
      return scannedTextList.length > 10;
    } on Exception catch (e) {
      print('Error in ReceiptService.imageHasText: $e');
      return false;
    }
  }
  
  static Future<String> extractPriceFromImage(String imagePath) async {
    String finalPrice;
    double finalValue = 0.00;
    String currencySign = '£';

    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // (\£|\$|\€): This will match any of the currency symbols (£, $, €).
    // (\d+): This will match one or more digits.
    // (\.\d{2})?: This will match the optional decimal point followed by exactly two digits.
    RegExp priceRegExp = RegExp(
      r'(\£|\$|\€)(\d+)(\.\d{2})?',
      multiLine: true,
      caseSensitive: false,
    );

    RegExp discardRegExp = RegExp(
      r'subtotal|savings|promotions|promotion|service|opt serv|points|point|voucher|tax|discount|vat|tip|service charge|coupon|membership|deposit|fee|delivery|shipping|promo|refund|adjustment|gift card',
      caseSensitive: false,
    );

    String scannedText = '';
    List<String> potentialPrices = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        if (discardRegExp.hasMatch(line.text)) continue;
        for (TextElement element in line.elements) {
          scannedText = element.text;
          if (priceRegExp.hasMatch(scannedText) == false) continue;
          if (scannedText == '') continue;
          if (potentialPrices.contains(scannedText)) continue;
          potentialPrices.add(scannedText);
          currencySign = scannedText[0];
        }
      }
    }

    for (final price in potentialPrices) {
      double? value = double.tryParse(price.trim().substring(1));
      if (value == null) continue;
      if (value < finalValue) continue;
      finalValue = value;
    }

    finalPrice = '$currencySign${finalValue.toStringAsFixed(2)}';

    // print('##################');
    // print(basename(imagePath));
    // print('potential prices: $potentialPrices');
    // print('finalValue: $finalValue');
    // print('finalPrice: $finalPrice');

    return finalPrice;
  }
}
