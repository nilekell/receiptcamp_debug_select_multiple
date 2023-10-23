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
      List<Object> items = [];
      List<ListItem> listItems = [];
      
      switch (selectedItem.item.runtimeType) {
        // if the selected item is a folder, do this
        case Folder:
          Folder selectedFolder = selectedItem.item as Folder;
          // getting all items including selected item
          items = await DatabaseRepository.instance
              .getFolderContents(selectedFolder.parentId);

          // removing selected folder
          items.removeWhere((element) {
            Folder? removedFolder;
            bool toBeRemoved = false;
            if (element is Folder) {
              removedFolder = element;
              toBeRemoved = element.id == selectedFolder.id;
            }
            if (toBeRemoved) print('SelectMultipleCubit: removing ${removedFolder!.name} from items');
            return toBeRemoved;
          });

          // adding all items except the selected item
          for (Object item in items) {
            listItems.add(ListItem(item: item));
          }

          emit(SelectMultipleActivated(items: listItems, initiallySelectedItem: ListItem(item: selectedFolder)));
          break;

        // if the selected item is a receipt, do this
        case Receipt:
          Receipt selectedReceipt = selectedItem.item as Receipt;
          final parentFolder = await DatabaseRepository.instance.getFolderById(selectedReceipt.parentId);
          items = await DatabaseRepository.instance
              .getFolderContents(selectedReceipt.parentId);

          // removing selected receipt
          items.removeWhere((element) {
            Receipt? removedReceipt;
              bool toBeRemoved = false;
              if (element is Receipt) {
                toBeRemoved = element.id == selectedReceipt.id;
              }
              if (toBeRemoved) print('SelectMultipleCubit: removing ${removedReceipt!.name} from items'); 
              return toBeRemoved;
            });

          // adding all items except the selected item
          for (Object item in items) {
            listItems.add(ListItem(item: item));
          }

          emit(SelectMultipleActivated(items: listItems, initiallySelectedItem: ListItem(item: selectedReceipt)));
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
