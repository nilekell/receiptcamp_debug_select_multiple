import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';

void showUploadOptions(BuildContext context) {
  showModalBottomSheet(
          context: context,
          builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from gallery'),
                    onTap: () {
                      context.read<UploadBloc>().add(UploadTapEvent());
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera),
                    title: const Text('Take a photo'),
                    onTap: () {
                      context.read<UploadBloc>().add(CameraTapEvent());
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
}