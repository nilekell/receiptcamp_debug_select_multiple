// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/data_constants.dart';
import 'package:receiptcamp/extensions/user_status_handler.dart';
import 'package:receiptcamp/logic/cubits/settings/settings_cubit.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        "Exporting...",
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
          case SettingsFileEmptyState():
            Navigator.of(context).pop();
            _showSettingsSnackBar(context, 'Cannot create an archive with no expenses');
          case SettingsFileErrorState():
            Navigator.of(context).pop();
            _showSettingsSnackBar(context, 'Uh oh, an error occured, please try again later');
            return;
          case SettingsFileLoadedState():
            Navigator.of(context).pop(); // hiding loading dialog
            context.read<SettingsCubit>().shareFolder(state.folder, state.file);
          case SettingsFileArchiveLoadedState():
            Navigator.of(context).pop(); 
            context.read<SettingsCubit>().shareArchive(state.file);
          default:
            return;
        }
      },
      child: Scaffold(
        backgroundColor: Color(primaryLightBlue),
        appBar: AppBar(
          backgroundColor: Color(primaryLightBlue),
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
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                            title: Text('Export all receipts',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,)),
                            onTap: () =>
                                context.read<SettingsCubit>().generateZipFile(),
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2,
                          height: 1,
                          indent: 25,
                          endIndent: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                            title: Text('Export archive',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Create a backup of all your expenses to import to another device.', style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,)),
                            ),
                            onTap: () =>
                                context.read<SettingsCubit>().generateArchive(),
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2,
                          height: 1,
                          indent: 25,
                          endIndent: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                            title: Text('Get ReceiptCamp Pro',
                                style: const TextStyle(
                                    fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  )),
                              onTap: () {
                                context.handleUserStatus((context) {
                                  showAdaptiveDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog.adaptive(
                                          content: const Text(
                                              'You are already a pro member.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Ok')),
                                          ],
                                        );
                                      });
                                });
                              }),
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2,
                          height: 1,
                          indent: 25,
                          endIndent: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                            title: Text('Restore purchases',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,)),
                            onTap: () {
                              context.handleUserStatus((context) {
                                  showAdaptiveDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog.adaptive(
                                          content: const Text(
                                              'You are already a pro member.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Ok')),
                                          ],
                                        );
                                      });
                                });
                            }
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2,
                          height: 1,
                          indent: 25,
                          endIndent: 25,
                        ),
                         Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                              title: Text('View Privacy Policy',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  )),
                              onTap: () async {
                                Navigator.of(context).pop();
                                final Uri url = Uri.parse(
                                    'https://docs.google.com/document/d/e/2PACX-1vQyYNZXBXuqvICH9vWKWeIP0EAgYHLSRl4m5pku5p1ctkWUPdfq8WKnFsmK2X5emdAcpUv2pnpi3hQx/pub');
                                if (!await launchUrl(url,
                                    mode: LaunchMode.inAppWebView)) {
                                  throw Exception('Could not launch $url');
                                }
                              }),
                        ),
                        const Divider(
                          color: Colors.white,
                          thickness: 2,
                          height: 1,
                          indent: 25,
                          endIndent: 25,
                        ),
                         Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                              title: Text('View EULA',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  )),
                              onTap: () async {
                                Navigator.of(context).pop();
                                final Uri url = Uri.parse(
                                    'https://docs.google.com/document/d/e/2PACX-1vTIpT-bu1pdkEyWmbdYy1KOrmZkRbDJ1F7MKLnfBr5n9c2T5FF9xFsUOXR1zys56cMLf-VeBHkyKXnp/pub');
                                if (!await launchUrl(url,
                                    mode: LaunchMode.inAppWebView)) {
                                  throw Exception('Could not launch $url');
                                }
                              }),
                        ),
                        const Divider(
                          color: Colors.white,
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
