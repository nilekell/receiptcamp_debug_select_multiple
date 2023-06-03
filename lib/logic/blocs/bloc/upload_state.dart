part of 'upload_bloc.dart';

abstract class UploadState extends Equatable {
  const UploadState();
  
  @override
  List<Object> get props => [];
}

class UploadInitial extends UploadState {}
