import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
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
  static Future<List<String>> extractKeywords(
      List<String> scannedOCRText) async {
    try {
      String scannedOCRTextList = scannedOCRText.join(' ');
      // Define the regular expression pattern for word characters.
      final pattern = RegExp(r'\w+');
      // Use the pattern to match all the words in the text.
      final matches = pattern.allMatches(scannedOCRTextList);
      // Convert the matches to a list of strings.
      final words = matches.map((match) => match.group(0)!).toList();

      final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
      final String detectedLanguage =
          await languageIdentifier.identifyLanguage(scannedOCRText.toString());

      // Use the _commonReceiptWords list as stop words.
      final commonReceiptWords = await loadCommonReceiptWords(detectedLanguage);
      // Filter out any stop words and return the remaining words.
      final keywords = words
          .where((word) => !commonReceiptWords.contains(word.toLowerCase()))
          .toSet() // Convert list to set to remove duplicates
          .toList(); // Convert set back to list

      languageIdentifier.close();
      return keywords;
    } on Exception catch (e) {
      print('Error in extractKeywords: $e');
      return [];
    }
  }

  @visibleForTesting
  // getting common skip words on receipt for latin languages only
  static Future<List<String>> loadCommonReceiptWords(
      String detectedLanguage) async {
    try {
      String fileName;

      switch (detectedLanguage) {
        case 'en':
          fileName = 'assets/common_receipt_words_english.txt';
          break;
        case 'es':
          fileName = 'assets/common_receipt_words_spanish.txt';
          break;
        case 'fr':
          fileName = 'assets/common_receipt_words_french.txt';
          break;
        case 'pt':
          fileName = 'assets/common_receipt_words_portuguese.txt';
          break;
        case 'de':
          fileName = 'assets/common_receipt_words_german.txt';
          break;
        case 'it':
          fileName = 'assets/common_receipt_words_italian.txt';
          break;
        case 'nl':
          fileName = 'assets/common_receipt_words_dutch.txt';
          break;
        case 'ro':
          fileName = 'assets/common_receipt_words_romanian.txt';
          break;
        default:
          fileName = 'assets/common_receipt_words_english.txt';
          break;
      }

      String content = await rootBundle.loadString(fileName);
      final commonReceiptWords =
          content.split('\n').map((word) => word.trim()).toList();
      return commonReceiptWords;
    } on Exception catch (e) {
      print('Error in loadCommonReceiptWords: $e');
      return <String>[];
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

    String finalPrice = '$currencySign${finalValue.toStringAsFixed(2)}';
    
    return finalPrice;
  }

  // getting words to discard in receipt when scanning for price
  // only for latin languages
  static Future<RegExp> getDiscardRegExp(String textToAnalyze) async {
    final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    final String detectedLanguage =
        await languageIdentifier.identifyLanguage(textToAnalyze);

    String discardRegExpPattern;

    switch (detectedLanguage) {
  case 'en': // English
    discardRegExpPattern =
        r'subtotal|savings|saving|promotions|promotion|service|opt serv|points|point|voucher|tax|discount|vat|tip|service charge|coupon|membership|deposit|fee|delivery|shipping|promo|refund|adjustment|gift card|add-on|extras|upgrade|surcharge|packaging|handling|convenience fee|loyalty|rewards|mileage|win|earn|chance';
    break;
  case 'fr': // French
    discardRegExpPattern =
        r'sous-total|économies|économie|promotions|promotion|service|opt serv|points|point|bon|taxe|rabais|tva|pourboire|frais de service|coupon|adhésion|dépôt|frais|livraison|expédition|promo|remboursement|ajustement|carte cadeau|supplément|extra|mise à niveau|supplément|emballage|manutention|frais de commodité|fidélité|récompenses|kilométrage|gagner|gagne|chance';
    break;
  case 'de': // German
    discardRegExpPattern =
        r'Teilsumme|Ersparnisse|Ersparnis|Aktionen|Aktion|Bedienung|Opt Dienst|Punkte|Punkt|Gutschein|Steuer|Rabatt|MwSt|Trinkgeld|Servicegebühr|Gutschein|Mitgliedschaft|Anzahlung|Gebühr|Lieferung|Versand|Promo|Rückerstattung|Anpassung|Geschenkkarte|Zusatz|Extras|Upgrade|Aufschlag|Verpackung|Handhabung|Komfortgebühr|Treue|Prämien|Kilometer|gewinnen|verdienen|Chance';
    break;
  case 'es': // Spanish
    discardRegExpPattern =
        r'subtotal|ahorros|ahorro|promociones|promoción|servicio|serv opc|puntos|punto|vale|impuesto|descuento|iva|propina|cargo de servicio|cupón|membresía|depósito|tarifa|entrega|envío|promo|reembolso|ajuste|tarjeta regalo|complemento|extras|mejora|recargo|embalaje|manipulación|cargo por comodidad|lealtad|recompensas|kilometraje|ganar|ganancia|oportunidad';
    break;
  case 'pt': // Portuguese
    discardRegExpPattern =
        r'subtotal|economias|economia|promoções|promoção|serviço|serv opc|pontos|ponto|vale|imposto|desconto|iva|gorjeta|taxa de serviço|cupom|associação|depósito|tarifa|entrega|remessa|promo|reembolso|ajuste|cartão presente|adicional|extras|melhoria|sobretaxa|embalagem|manuseio|taxa de conveniência|lealdade|recompensas|quilometragem|ganhar|ganho|chance';
    break;
  case 'it': // Italian
    discardRegExpPattern =
        r'subtotale|risparmi|risparmio|promozioni|promozione|servizio|serv opt|punti|punto|buono|tassa|sconto|IVA|mancia|spesa di servizio|coupon|adesione|deposito|tariffa|consegna|spedizione|promo|rimborso|aggiustamento|buono regalo|extra|extras|aggiornamento|sovrattassa|imballaggio|maneggiamento|tassa di comodità|lealtà|ricompense|chilometraggio|vincere|guadagnare|opportunità';
    break;
  case 'ro': // Romanian
    discardRegExpPattern =
        r'subtotal|economii|economie|promoții|promoție|serviciu|serv opț|puncte|punct|tichet|taxă|reducere|TVA|bacșiș|taxă de serviciu|cupon|membru|depozit|tarif|livrare|transport|promo|rambursare|ajustare|card cadou|suplimentar|extra|actualizare|suprataxă|ambalaj|manipulare|taxa de comoditate|loialitate|recompense|kilometraj|câștiga|câștig|șansă';
    break;
  case 'nl': // Dutch
    discardRegExpPattern =
        r"subtotaal|besparingen|besparing|promoties|promotie|service|opt serv|punten|punt|voucher|belasting|korting|btw|fooien|servicekosten|coupon|lidmaatschap|aanbetaling|vergoeding|bezorging|verzending|promo|terugbetaling|aanpassing|cadeaubon|toevoeging|extra's|upgrade|toeslag|verpakking|afhandeling|gemaksvergoeding|loyaliteit|beloningen|kilometerstand|winnen|verdienen|kans";
    break;
  default: // Default to English
    discardRegExpPattern =
        r'subtotal|savings|saving|promotions|promotion|service|opt serv|points|point|voucher|tax|discount|vat|tip|service charge|coupon|membership|deposit|fee|delivery|shipping|promo|refund|adjustment|gift card|add-on|extras|upgrade|surcharge|packaging|handling|convenience fee|loyalty|rewards|mileage|win|earn|chance';
    break;
}


    RegExp discardRegExp = RegExp(
      discardRegExpPattern,
      caseSensitive: false,
    );

    languageIdentifier.close();

    return discardRegExp;
  }
}
