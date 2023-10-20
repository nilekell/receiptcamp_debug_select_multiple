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

final class SharingIntentLoading extends SharingIntentState {}

final class SharingIntentNoValidFiles extends SharingIntentState {}

final class SharingIntentError extends SharingIntentState {}

final class SharingIntentSuccess extends SharingIntentState {
  final List<Folder> folders;

  const SharingIntentSuccess({required this.folders});

  @override
  List<Object> get props => [folders];
}

final class SharingIntentSavingReceipts extends SharingIntentSuccess {
  const SharingIntentSavingReceipts({required super.folders});
}

final class SharingIntentClose extends SharingIntentSuccess {
  final List<Receipt> savedReceipts;
  const SharingIntentClose({required super.folders, required this.savedReceipts});
}
