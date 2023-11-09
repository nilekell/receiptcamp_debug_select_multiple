part of 'sharing_intent_cubit.dart';

sealed class SharingIntentState extends Equatable {
  const SharingIntentState();

  @override
  List<Object> get props => [];
}

final class SharingIntentFilesInitial extends SharingIntentState {}

final class SharingIntentFilesRecieved extends SharingIntentState {
  final List<File> files;

  const SharingIntentFilesRecieved({required this.files});

  @override
  List<Object> get props => [files];
  
}

final class SharingIntentZipFileReceived extends SharingIntentState {
  final File zipFile;

  const SharingIntentZipFileReceived({required this.zipFile});

  @override
  List<Object> get props => [zipFile];
}

final class SharingIntentLoading extends SharingIntentState {}

final class SharingIntentNoValidFiles extends SharingIntentState {}

final class SharingIntentError extends SharingIntentState {}

final class SharingIntentSuccess extends SharingIntentState {
  final List<Folder> folders;

  const SharingIntentSuccess({required this.folders});

  @override
  List<Object> get props => [folders];
}

final class SharingIntentArchiveSuccess extends SharingIntentState {
  final List<Object> items;
  final List<File> imageFiles;
  final Map<String, File> receiptImageMap;

  const SharingIntentArchiveSuccess({required this.items, required this.imageFiles, required this.receiptImageMap});

  @override
  List<Object> get props => [items, imageFiles, receiptImageMap];
}

final class SharingIntentSavingArchive extends SharingIntentArchiveSuccess {
  const SharingIntentSavingArchive({required super.imageFiles, required super.items, required super.receiptImageMap});

  @override
  List<Object> get props => [items, imageFiles];
}

final class SharingIntentArchiveClose extends SharingIntentArchiveSuccess{
  const SharingIntentArchiveClose({required super.imageFiles, required super.items, required super.receiptImageMap});

  @override
  List<Object> get props => [items, imageFiles];
}

final class SharingIntentInvalidArchive extends SharingIntentState {}

final class SharingIntentSavingReceipts extends SharingIntentSuccess {
  const SharingIntentSavingReceipts({required super.folders});
}

final class SharingIntentClose extends SharingIntentSuccess {
  final List<Receipt> savedReceipts;
  const SharingIntentClose({required super.folders, required this.savedReceipts});
}
