import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(UploadInitial()) {
    on<UploadInitialEvent>(uploadInitialEvent);
    on<UploadTapEvent>(uploadTapEvent);
    on<CameraTapEvent>(cameraTapEvent);
  }

    FutureOr<void> uploadInitialEvent(event, Emitter<UploadState> emit) {
      print('uploadInitialEvent');
  }

  FutureOr<void> uploadTapEvent(UploadTapEvent event, Emitter<UploadState> emit) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? receiptImage = await imagePicker.pickImage(source: ImageSource.gallery);
  }

  FutureOr<void> cameraTapEvent(event, Emitter<UploadState> emit) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? receiptPicture = await imagePicker.pickImage(source: ImageSource.camera);
  }


}
