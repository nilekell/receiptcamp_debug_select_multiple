import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'receipt_upload_state.dart';

class ReceiptUploadCubit extends Cubit<ReceiptUploadState> {
  ReceiptUploadCubit() : super(ReceiptUploadInitial());
}
