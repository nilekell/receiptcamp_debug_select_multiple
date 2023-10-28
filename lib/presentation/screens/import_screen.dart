import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/sharing_intent/sharing_intent_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class SlidingImportTransitionRoute extends PageRouteBuilder {
  final File zipFile;

  SlidingImportTransitionRoute({required this.zipFile})
      : super(
          opaque: false,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return Dismissible(
              onDismissed: (direction) {
                Navigator.of(context).pop();
              },
              key: UniqueKey(),
              direction: DismissDirection.down,
              child: ImportView(zipFile: zipFile,),
            );
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;

            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: BlocProvider.value(
                value: context.read<SharingIntentCubit>(),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class ImportView extends StatefulWidget {
  const ImportView({super.key, required this.zipFile});

  final File zipFile;


  @override
  State<ImportView> createState() => _ImportViewState();
}

final titleMainAxisSize =
    Platform.isAndroid ? MainAxisSize.max : MainAxisSize.min;

class _ImportViewState extends State<ImportView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
            data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent),
            child: BottomNavigationBar(
                onTap: null,
                backgroundColor: const Color(primaryDarkBlue),
                items: const [
                  BottomNavigationBarItem(icon: Text(''), label: ''),
                  BottomNavigationBarItem(
                    icon: Text(''),
                    label: '',
                  )
                ]),
          ),
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(
              Icons.close,
              size: 26,
            ),
            onPressed: () => Navigator.of(context).pop()),
        backgroundColor: const Color(primaryDarkBlue),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: titleMainAxisSize,
          children: const [
            Text(
              'Import receipts',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () {
                // start saving folders and receipts
                // show loading dialog while this occurs
              })
        ],
      ),
      body: BlocBuilder<SharingIntentCubit, SharingIntentState>(
        builder: (context, state) {
          return Container();
        },
      ),
    );
  }
}
