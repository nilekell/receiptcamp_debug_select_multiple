part of 'sharing_intent_cubit.dart';

sealed class SharingIntentState extends Equatable {
  const SharingIntentState();

  @override
  List<Object> get props => [];
}

final class SharingIntentFilesRecieved extends SharingIntentState {}

final class SharingIntentLoading extends SharingIntentState {}

final class SharingIntentSuccess extends SharingIntentState {
  final List<Folder> folders;
  final List<File> files;

  const SharingIntentSuccess({required this.folders, required this.files});

}

final class SharingIntentError extends SharingIntentState {}
