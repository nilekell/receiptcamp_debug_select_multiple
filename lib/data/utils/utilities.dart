import 'dart:math';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum ImageFileType {png, heic, jpg, jpeg}

class Utility {
  static int getCurrentTime() {
    try {
      DateTime dateTimeNow = DateTime.now();
      int unixTimestamp = (dateTimeNow.millisecondsSinceEpoch / 1000).round();
      return unixTimestamp;
    } catch (e) {
      print('Error in getCurrentTime: $e');
      rethrow;
    }
  }

  static String formatDateTimeFromUnixTimestamp(int unixTimestamp) {
    try {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
      String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      return formattedDateTime;
    } catch (e) {
      print('Error in formatDateTimeFromUnixTimestamp: $e');
      rethrow;
    }
  }

  static int formatUnixTimeStampFromDateTime(String formattedDateTime) {
    try {
      DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedDateTime);
      int unixTimestamp = dateTime.millisecondsSinceEpoch ~/ 1000;
      return unixTimestamp;
    } catch (e) {
      print('Error in formatUnixTimeStampFromDateTime: $e');
      rethrow;
    }
  }

  static String formatDisplayDateFromDateTime(String formattedDateTime) {
    try {
      final originalFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final targetFormat = DateFormat('d MMMM yyyy');
      DateTime dateTime = originalFormat.parse(formattedDateTime);
      return targetFormat.format(dateTime);
    } catch (e) {
      print('Error in formatDisplayDateFromDateTime: $e');
      rethrow;
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
      rethrow;
    }
  }

  static String generateUid() {
    try {
      String uid = const Uuid().v4().toString();
      return uid;
    } catch (e) {
      print('Error in generateUid: $e');
      rethrow;
    }
  }
}

