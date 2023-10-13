// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// class to model folder object in database to store receipts and other folders
class Folder {
  final String id;
  final String name;
  final int lastModified;
  final String parentId;

  Folder(
      {required this.id,
      required this.name,
      required this.lastModified,
      required this.parentId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'parentId': parentId,
      'lastModified': lastModified
    };
  }

  factory Folder.fromMap(Map<dynamic, dynamic> map) {
    return Folder(
        id: map['id'] as String,
        name: map['name'] as String,
        parentId: map['parentId'] as String,
        lastModified: map['lastModified'] as int);
  }

  String toJson() => json.encode(toMap());

  factory Folder.fromJson(String source) =>
      Folder.fromMap(json.decode(source) as Map<String, dynamic>);
}

class FolderWithSize extends Folder {
  final Folder folder;
  final int storageSize;

  FolderWithSize({required this.storageSize, required this.folder})
      : super(
            id: folder.id,
            name: folder.name,
            lastModified: folder.lastModified,
            parentId: folder.parentId);
}
