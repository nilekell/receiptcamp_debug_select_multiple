import 'package:flutter_test/flutter_test.dart';
import 'package:receiptcamp/data/utils/utilities.dart';

void main() {
  group('Utility', () {
    test('getCurrentTime returns a valid unix timestamp', () {
      int timestamp = Utility.getCurrentTime();
      expect(timestamp, isNotNull);
      expect(timestamp, isA<int>());
    });

    test('formatDateTimeFromUnixTimestamp returns a valid formatted date', () {
      int timestamp = Utility.getCurrentTime();
      String formattedDate = Utility.formatDateTimeFromUnixTimestamp(timestamp);
      expect(formattedDate, isNotNull);
      expect(formattedDate, isA<String>());
      // Matches YYYY-MM-DD HH:MM:SS
      expect(formattedDate,
          matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')));
    });

    test('formatUnixTimeStampFromDateTime returns a valid unix timestamp', () {
      int timestamp = Utility.getCurrentTime();
      String formattedDate = Utility.formatDateTimeFromUnixTimestamp(timestamp);
      int newTimestamp = Utility.formatUnixTimeStampFromDateTime(formattedDate);
      expect(newTimestamp, isNotNull);
      expect(newTimestamp, isA<int>());
      expect(newTimestamp, equals(timestamp));
      // max length of 64-bit unix timestamp is 19 characters
      expect(newTimestamp.toString().length, lessThanOrEqualTo(19));
    });

    test('formatDisplayDateFromDateTime returns a valid display date', () {
      int timestamp = Utility.getCurrentTime();
      String formattedDate = Utility.formatDateTimeFromUnixTimestamp(timestamp);
      String displayDate = Utility.formatDisplayDateFromDateTime(formattedDate);
      expect(displayDate, isNotNull);
      expect(displayDate, isA<String>());
      // Matches D MMMM YYYY
      expect(displayDate, matches(RegExp(r'^\d{1,2} \w+ \d{4}$')));
    });

    test('bytesToSizeString returns a valid size string', () {
      String sizeString = Utility.bytesToSizeString(1024);
      expect(sizeString, isNotNull);
      expect(sizeString, isA<String>());
      expect(sizeString, equals('1.00 KB'));
      // Matches size format with 2 decimal places
      expect(sizeString, matches(RegExp(r'^\d+(\.\d{2})? (B|KB|MB|GB)$')));
    });

    test('generateUid returns a valid uid', () {
      String uid = Utility.generateUid();
      expect(uid, isNotNull);
      expect(uid, isA<String>());
      expect(uid.length, equals(36)); // UUIDs are 36 characters long
    });
  });
}
