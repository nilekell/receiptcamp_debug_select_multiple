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

  void activate(ListItem selectedItem) async {
    emit(SelectMultipleLoading());

    try {
      // Get the parent ID and type of the selected item
      String parentId;
      dynamic selectedObject;

      if (selectedItem.item is Folder) {
        parentId = (selectedItem.item as Folder).parentId;
        selectedObject = selectedItem.item as Folder;
      } else if (selectedItem.item is Receipt) {
        parentId = (selectedItem.item as Receipt).parentId;
        selectedObject = selectedItem.item as Receipt;
      } else {
        emit(SelectMultipleError());
        return;
      }

      // Fetch all items from the parent ID
      List<Object> items =
          await DatabaseRepository.instance.getFolderContents(parentId);

      // Remove the selected item from the list
      items.removeWhere((element) {
        if (element is Folder && selectedObject is Folder) {
          return element.id == selectedObject.id;
        } else if (element is Receipt && selectedObject is Receipt) {
          return element.id == selectedObject.id;
        }
        return false;
      });

      // Convert items to ListItems
      List<ListItem> listItems =
          items.map((item) => ListItem(item: item)).toList();

      emit(SelectMultipleActivated(
          items: listItems, initiallySelectedItem: selectedItem));
    } on Exception catch (e) {
      print(e.toString());
      emit(SelectMultipleError());
    }
  }
}
