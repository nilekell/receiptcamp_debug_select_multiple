// ignore_for_file: avoid_types_as_parameter_names, non_constant_identifier_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/utils/utilities.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/screens/error_view.dart';
import 'package:receiptcamp/presentation/screens/image_view.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

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
          return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 300),
                // provide some space between image and text
                Text(
                  "No recent receipts",
                  style: TextStyle(
                      color: Color(primaryGrey),
                      fontSize: 25,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "To see recents, add receipts to ReceiptCamp",
                  style: TextStyle(
                      color: Color(primaryGrey),
                      fontSize: 16,
                      fontWeight: FontWeight.w100),
                  textAlign: TextAlign.center,
                ),
              ]);
        case HomeLoadedSuccessState():
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<HomeBloc>().add(HomeInitialEvent());
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      // key preserves scroll position when switching tabs
                      key: const PageStorageKey<String>('HomeKey'),
                      itemCount: state.receipts.length,
                      itemBuilder: (context, index) {
                        final receipt = state.receipts[index];
                        return Column(
                          children: [
                            index == 0 ? const Padding(padding: EdgeInsetsDirectional.only(top: 24.0)) : const SizedBox.shrink(),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height / 3,
                              child: HomeReceiptTile(
                                receipt: receipt,
                              ),
                            ),
                            index !=
                                state.receipts.length -
                                    1 ? // Check to not add a divider after the last item, instead add padding
                              Divider(
                                // how much space divider occupies vertically
                                height: 40.0,
                                  thickness: 1.0,
                                  indent: 20.0,
                                  endIndent: 20.0,
                                  color: Colors.grey[
                                      400]) : const Padding(padding: EdgeInsetsDirectional.symmetric(vertical: 8.0)),
                          ],
                        );
                      },
                    )),
              ),
            ],
          );
        default:
          print('Home Screen: ${state.toString()}');
          return const ErrorView();
      }
    });
  }
}

class HomeReceiptTile extends StatelessWidget {
  HomeReceiptTile({Key? key, required this.receipt})
      // displayName is the file name without the file extension and is cut off when the receipt name
      // is > 25 chars or would require 2 lines to be shown completely
      : displayName = receipt.name.length > 30
            ? "${receipt.name.substring(0, 30)}...".split('.').first
            : receipt.name.split('.').first,
        displayDate = Utility.formatDisplayDateFromDateTime(
            Utility.formatDateTimeFromUnixTimestamp(receipt.lastModified)),
        super(key: key);

  final String displayName;
  final Receipt receipt;
  final String displayDate;

  final titleTextStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  final subTitleTextStyle = const TextStyle(fontSize: 16.0, color: Color(primaryGrey));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(SlidingImageTransitionRoute(receipt: receipt));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              displayName.length > 30 ? '${displayName.substring(0,30)}...' : displayName,
              style: titleTextStyle,
            ),
          ),
          Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                          decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(40.0)), // rounding border corners
                border: Border.all(
                  color: const Color(primaryLightBlue), // border color
                  width: 2, // border width
                ),
                          ),
                          child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(40.0)), // rounding image corners
                child: Image.file(
                  File(receipt.localPath),
                  fit: BoxFit.cover,
                ),
                          ),
                        ),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Created on $displayDate',
              style: subTitleTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
