part of 'receipt_upload_cubit.dart';

abstract class ReceiptUploadState extends Equatable {
  const ReceiptUploadState();

  @override
  List<Object> get props => [];
}

class ReceiptUploadInitial extends ReceiptUploadState {}

class ReceiptUploadLoading extends ReceiptUploadState {}

class ReceiptUploadComplete extends ReceiptUploadState {}

class ReceiptUploadFailure extends ReceiptUploadState {}
