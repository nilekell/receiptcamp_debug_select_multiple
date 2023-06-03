import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/ui/home/app_bar.dart';
import 'package:receiptcamp/presentation/ui/home/drawer.dart';
import 'package:receiptcamp/presentation/ui/home/nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadBloc, UploadState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        return Scaffold(
            drawer: const NavDrawer(),
            appBar: const HomeAppBar(),
            body: const Placeholder(),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<UploadBloc>().add(CameraTapEvent());
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.camera_alt),
            ),
            bottomNavigationBar: NavBar());
      },
    );
  }
}
