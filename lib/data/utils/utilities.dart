import 'dart:math';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Utility {
  static int getCurrentTime() {
    try {
      DateTime dateTimeNow = DateTime.now();
      int unixTimestamp = (dateTimeNow.millisecondsSinceEpoch / 1000).round();
      return unixTimestamp;
    } catch (e) {
      print('Error in getCurrentTime: $e');
      throw e;
    }
  }

  static String formatDateTimeFromUnixTimestamp(int unixTimestamp) {
    try {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
      String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      return formattedDateTime;
    } catch (e) {
      print('Error in formatDateTimeFromUnixTimestamp: $e');
      throw e;
    }
  }

  static int formatUnixTimeStampFromDateTime(String formattedDateTime) {
    try {
      DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedDateTime);
      int unixTimestamp = dateTime.millisecondsSinceEpoch ~/ 1000;
      return unixTimestamp;
    } catch (e) {
      print('Error in formatUnixTimeStampFromDateTime: $e');
      throw e;
    }
  }

  static Future<String> bytesToSizeString(int bytes) async {
    try {
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB"];
      var i = (log(bytes) / log(1024)).floor();
      return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
    } catch (e) {
      print('Error in bytesToSizeString: $e');
      throw e;
    }
  }

  static String generateFileName() {
    try {
      const Uuid uuid = Uuid();
      final String myUuidString = uuid.v4().toString();
      String fileName = 'RCPT_IMG_$myUuidString.jpg';
      return fileName;
    } catch (e) {
      print('Error in generateFileName: $e');
      throw e;
    }
  }

  static String generateUid() {
    try {
      String uid = const Uuid().v4().toString();
      return uid;
    } catch (e) {
      print('Error in generateUid: $e');
      throw e;
    }
  }
}

