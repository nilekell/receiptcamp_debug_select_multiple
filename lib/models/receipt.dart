// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:receiptcamp/data/services/document_path_provider.dart';

// class to model receipts to be stored in sql db
class Receipt {
  final String id;
  final String name;
  final String fileName;
  final int dateCreated;
  final int lastModified;
  // this is in bytes
  final int storageSize;
  // the id of the folder that holds this receipt
  final String parentId;

  // builds and returns the full path of the receipt's image based on the app's
  // current application document directory path
  String get localPath => '${DocumentDirectoryProvider.instance.appDocDirPath}/$fileName';

  Receipt(
      {required this.id,
      required this.name,
      required this.fileName,
      required this.dateCreated,
      required this.lastModified,
      required this.storageSize,
      required this.parentId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'fileName': fileName,
      'dateCreated': dateCreated,
      'lastModified': lastModified,
      'storageSize': storageSize,
      'parentId': parentId
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
        id: map['id'] as String,
        name: map['name'] as String,
        fileName: map['fileName'] as String,
        dateCreated: map['dateCreated'] as int,
        lastModified: map['lastModified'] as int,
        storageSize: map['storageSize'] as int,
        parentId: map['parentId'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Receipt.fromJson(String source) => Receipt.fromMap(json.decode(source) as Map<String, dynamic>);
}
