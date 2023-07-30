import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/folder_view/folder_view_cubit.dart';
import 'package:receiptcamp/models/receipt.dart';

Future<void> showDeleteReceiptDialog(BuildContext context,
    FolderViewCubit folderViewCubit, Receipt receipt) async {
  return await showDialog(
    context: context,
    builder: (deleteReceiptDialogContext) {
      return BlocProvider.value(
        value: folderViewCubit,
        child: DeleteReceiptDialog(receipt: receipt)
      );
    },
  );
}

class DeleteReceiptDialog extends StatelessWidget {
  final Receipt receipt;

  const DeleteReceiptDialog({
    super.key, required this.receipt
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete forever?', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w500),),
      content: Text('${receipt.name} will be deleted forever.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            context.read<FolderViewCubit>().deleteReceipt(receipt.id);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
