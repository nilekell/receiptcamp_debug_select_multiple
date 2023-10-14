part of 'confirm_receipt_cubit.dart';

sealed class ConfirmReceiptState extends Equatable {
  const ConfirmReceiptState();

  @override
  List<Object> get props => [];
}

final class ConfirmReceiptInitial extends ConfirmReceiptState {}

final class ConfirmReceiptLoading extends ConfirmReceiptState {}

final class ConfirmReceiptSuccess extends ConfirmReceiptState {
  final List<ExcelReceipt> excelReceipts;

  const ConfirmReceiptSuccess({required this.excelReceipts});

  @override
  List<Object> get props => [excelReceipts];
}

final class ConfirmReceiptFileLoading extends ConfirmReceiptSuccess {
  const ConfirmReceiptFileLoading({required super.excelReceipts});

  @override
  List<Object> get props => [excelReceipts];
}

final class ConfirmReceiptFileLoaded extends ConfirmReceiptSuccess {

  final File excelFile;

  const ConfirmReceiptFileLoaded({required this.excelFile, required super.excelReceipts});

  @override
  List<Object> get props => [excelFile, excelReceipts];
}

final class ConfirmReceiptFileClose extends ConfirmReceiptSuccess {
  const ConfirmReceiptFileClose({required super.excelReceipts});
}

final class ConfirmReceiptFileError extends ConfirmReceiptSuccess {
  const ConfirmReceiptFileError({required super.excelReceipts});
}

final class ConfirmReceiptEmpty extends ConfirmReceiptState {
}

final class ConfirmReceiptError extends ConfirmReceiptState {}