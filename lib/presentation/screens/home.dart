// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
import 'package:receiptcamp/models/receipt.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      switch (state) {
        case HomeInitialState():
          return const CircularProgressIndicator();
        case HomeLoadingState():
          return const CircularProgressIndicator();
        case HomeErrorState():
          return const Text('Error showing receipts');
        case HomeEmptyReceiptsState():
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      height: 20), // provide some space between image and text
                  Text(
                    "You haven't saved any receipts yet :(",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "To start saving receipts, navigate to folders and press the upload button",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        case HomeLoadedSuccessState():
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<HomeBloc>().add(HomeInitialEvent());
                    },
                    child: ListView.builder(
                      itemCount: state.receipts.length,
                      itemBuilder: (context, index) {
                        final receipt = state.receipts[index];
                        final formattedDateTime =
                            Utility.formatDateTimeFromUnixTimestamp(
                                receipt.dateCreated);
                        final displayDate =
                            Utility.formatDisplayDateFromDateTime(
                                formattedDateTime);
                        String displayName = receipt.name.length > 15
                            ? "${receipt.name.substring(0, 15)}..."
                            : receipt.name;
                        return GestureDetector(
                          onTap: () {
                            final imageProvider =
                                Image.file(File(receipt.localPath)).image;
                            showImageViewer(context, imageProvider);
                          },
                          child: Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height / 3,
                            padding: const EdgeInsets.all(
                                4.0), // padding between each card
                            child: HomeReceiptTile(displayName: displayName, receipt: receipt, displayDate: displayDate),
                          ),
                        );
                      },
                    )),
              ),
            ],
          );
        default:
          print('Home Screen: ${state.toString()}');
          return Container();
      }
    });
  }
}

class HomeReceiptTile extends StatelessWidget {
  const HomeReceiptTile({
    super.key,
    required this.displayName,
    required this.receipt,
    required this.displayDate,
  });

  final String displayName;
  final Receipt receipt;
  final String displayDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        // Card's rounded edges
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              displayName,
              style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              // round the image corners
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15.0)),
              child: Image.file(
                File(receipt.localPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Created on $displayDate',
              style: const TextStyle(
                  fontSize: 14.0, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
