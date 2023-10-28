// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/logic/cubits/settings/settings_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class SlidingSettingsRoute extends PageRouteBuilder {
  SlidingSettingsRoute()
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
              child: const SettingsView(),
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
                value: context.read<SettingsCubit>(),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  void _showSettingsSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Color(primaryDeepBlue),
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      duration: Duration(milliseconds: 2000),
    ));
  }

  Future<void> _showProcessingDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(40.0))),
            backgroundColor: const Color(primaryDeepBlue),
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      child: const Text(
                        "Creating archive of all receipts...",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            ),
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => previous is SettingsFileState || current is SettingsFileState,
      listener: (context, state) {
        switch (state) {
          case SettingsFileLoadingState():
            _showProcessingDialog(context);
            return;
          case SettingsFileErrorState():
            _showSettingsSnackBar(context, 'Uh oh, an error occured, please try again later');
            return;
          case SettingsFileLoadedState():
            Navigator.of(context).pop(); // hiding loading dialog
            context.read<SettingsCubit>().shareFolder(state.folder, state.file);
          default:
            return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(primaryDarkBlue),
          elevation: 0.0,
          title: Text('Settings'),
          leading: IconButton(
              icon: const Icon(
                Icons.close,
                size: 26,
              ),
              onPressed: () => Navigator.of(context).pop()),
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            switch (state) {
              case SettingsInitial() || SettingsLoading():
                return const CircularProgressIndicator();
              case SettingsError():
                return const Center(
                  child:
                      Text('Uh oh, an error occured, please try again later.'),
                );
              case SettingsSuccess():
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 300,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                            title: Text('Export all receipts',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color(primaryGrey))),
                            onTap: () =>
                                context.read<SettingsCubit>().generateZipFile(),
                          ),
                        ),
                        const Divider(
                          thickness: 2,
                          height: 1,
                          indent: 25,
                          endIndent: 25,
                        ),
                        SizedBox(height: 50,),
                        Text(appVersion, style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,),)
                      ],
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
