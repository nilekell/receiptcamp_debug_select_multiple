import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/select_multple/select_multiple_cubit.dart';
import 'package:receiptcamp/presentation/screens/select_multiple_screen.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

Future<void> showMultiDeleteDialog(BuildContext context,
    SelectMultipleCubit selectMultipleCubit, Object selectedObject, List<ListItem> itemsToBeDeleted) async {
  return await showDialog(
    context: context,
    builder: (deleteReceiptDialogContext) {
      return BlocProvider.value(
          value: selectMultipleCubit, child: MultiDeleteDialog(itemsToBeDeleted: itemsToBeDeleted));
    },
  );
}

class MultiDeleteDialog extends StatelessWidget {
  final List<ListItem> itemsToBeDeleted;

  MultiDeleteDialog({super.key, required this.itemsToBeDeleted});

  final ButtonStyle textButtonStyle =
      TextButton.styleFrom(foregroundColor: Colors.white);

  final TextStyle actionButtonTextStyle = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0))),
      backgroundColor: const Color(primaryDarkBlue),
      title: const Text(
        'Delete forever?',
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      ),
      content: Text(itemsToBeDeleted.length > 1 ?
        'Move ${itemsToBeDeleted.length} items to...' :
        'Move ${itemsToBeDeleted.length} item to...',
          style: const TextStyle(color: Colors.white)),
      actions: <Widget>[
        TextButton(
          style: textButtonStyle,
          child: Text('Cancel', style: actionButtonTextStyle),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: textButtonStyle,
          child: Text('Delete', style: actionButtonTextStyle),
          onPressed: () {
            context.read<SelectMultipleCubit>().deleteMultiItems(itemsToBeDeleted);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
