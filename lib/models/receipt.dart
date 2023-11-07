// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:receiptcamp/data/services/directory_path_provider.dart';

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
  String get localPath => '${DirectoryPathProvider.instance.appDocDirPath}/$fileName';

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

  Receipt.fromMap(Map<String, dynamic> map)
    : id = map['id'],
      name = map['name'],
      fileName = map['fileName'],
      dateCreated = map['dateCreated'],
      lastModified = map['lastModified'],
      storageSize = map['storageSize'],
      parentId = map['parentId'];

  String toJson() => json.encode(toMap());

  factory Receipt.fromJson(String source) => Receipt.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ReceiptWithSize extends Receipt {
  final bool withSize;
  final Receipt receipt;

  ReceiptWithSize({required this.withSize, required this.receipt}) : super(id: receipt.id, name: receipt.name, fileName: receipt.fileName, dateCreated: receipt.dateCreated, lastModified: receipt.lastModified, storageSize: receipt.storageSize, parentId: receipt.parentId);
}

class ReceiptWithPrice extends Receipt {
  final String priceString;
  final double priceDouble;
  final Receipt receipt;

  ReceiptWithPrice({required this.receipt, required this.priceString, required this.priceDouble}) : super(id: receipt.id, name: receipt.name, fileName: receipt.fileName, dateCreated: receipt.dateCreated, lastModified: receipt.lastModified, storageSize: receipt.storageSize, parentId: receipt.parentId);
}

class ExcelReceipt extends Receipt {
  String price;

  ExcelReceipt({required this.price, required Receipt receipt})
      : super(
            id: receipt.id,
            name: receipt.name,
            fileName: receipt.fileName,
            dateCreated: receipt.dateCreated,
            lastModified: receipt.lastModified,
            storageSize: receipt.storageSize,
            parentId: receipt.parentId);

  ExcelReceipt.fromMap(Map<String, dynamic> map)
      : price = map['price'],
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> superMap = super.toMap();
    superMap['price'] = price;
    return superMap;
  }
}
