// class to model receipt tags extracted from OCR and create object to store in database
class Tag {
  final String id;
  final String receiptId;
  final String tag;

  const Tag({
    required this.id, 
    required this.receiptId, 
    required this.tag});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receiptId': receiptId,
      'tag': tag
    };
      
    }
}