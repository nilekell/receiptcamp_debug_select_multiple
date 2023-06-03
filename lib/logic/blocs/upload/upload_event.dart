// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'upload_bloc.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  // props declared when we want State to be compared against the values
  // declared inside props List
  @override
  List<Object> get props => [];
}

class UploadInitialEvent extends UploadEvent {}

class UploadTapEvent extends UploadEvent {}

class CameraTapEvent extends UploadEvent {}