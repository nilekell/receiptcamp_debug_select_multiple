// ignore_for_file: unused_local_variable
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/models/folder.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/screens/select_multiple_screen.dart';

part 'select_multiple_state.dart';

class SelectMultipleCubit extends Cubit<SelectMultipleState> {
  SelectMultipleCubit() : super(SelectMultipleInitial());

  void init(ListItem selectedItem) {
    emit(SelectMultipleInitial());
    activate(selectedItem);
  }

  void activate(Object selectedItem) async {
    emit(SelectMultipleLoading());
    try {
      List<Object> items = [];
      switch (selectedItem.runtimeType) {
        case Folder:
          Folder selectedFolder = selectedItem as Folder;
            items = await DatabaseRepository.instance
                .getFolderContents(selectedFolder.parentId);
            emit(SelectMultipleActivated(initiallySelectedItem: selectedFolder, items: items, selectedItemParentFolder: selectedFolder));
            break;

        case Receipt:
          Receipt selectedReceipt = selectedItem as Receipt;
          final parentFolder = await DatabaseRepository.instance.getFolderById(selectedReceipt.parentId);
          items = await DatabaseRepository.instance
              .getFolderContents(selectedReceipt.parentId);
          emit(SelectMultipleActivated(initiallySelectedItem: selectedReceipt, items: items, selectedItemParentFolder: parentFolder));
          break;

        default:
          emit(SelectMultipleError());
      }

    } on Exception catch (e) {
      print(e.toString());
      emit(SelectMultipleError());
    }
  }
}
