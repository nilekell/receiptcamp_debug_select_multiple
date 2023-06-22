part of 'upload_bloc.dart';

sealed class UploadState extends Equatable {
  const UploadState();
  
  @override
  List<Object> get props => [];
}

final class UploadInitial extends UploadState {}

final class UploadLoading extends UploadState {}

final class UploadReceiptSuccess extends UploadState {
  const UploadReceiptSuccess({required this.receipt});

  final Receipt receipt;
}

final class UploadFolderSuccess extends UploadState {
  const UploadFolderSuccess({required this.folder});

  final Folder folder;
}

final class UploadFailed extends UploadState {}
