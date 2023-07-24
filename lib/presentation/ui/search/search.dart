import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/search/search_bloc.dart';
import 'package:receiptcamp/presentation/screens/file_explorer.dart';

class CustomSearchDelegate extends SearchDelegate {
  final SearchBloc searchBloc;

  CustomSearchDelegate({required this.searchBloc}) : super();
  
  // first overridden method to build ui that appears after search field
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          // query is the current string shown in the AppBar
          // resetting query to empty string
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  // second overridden method to build ui that appears before search field
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        // closing search delegate
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  // third overridden method to show the querying process at the runtime
  // method is called when the user submits a query in the keyboard
  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return ListView(
          children: const [
            Text('result 1'),
            Text('result 2'),
            Text('result 3'),
          ],
        );
      },
    );
  }

  // last overridden method to show the querying process at the runtime
  // method is called whenever the content of [query] changes
  @override
  Widget buildSuggestions(BuildContext context) {
    searchBloc.add(TextChanged(text: query.trim().toLowerCase()));

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        switch (state) {
          case SearchInitial():
            return Container();
          case SearchStateLoading():
            return const Center(child: CircularProgressIndicator());
          case SearchStateEmpty():
            return const Center(child: Text("Sorry, we couldn't find any results"));
          case SearchStateSuccess():
            return Scrollbar(
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final receipt = state.items[index];
                  return ReceiptListTile(receipt: receipt);
                }));
          case SearchStateError():
            return const Center(child:Text('Sorry, an unexpected error occured, please try again'));
          default:
            return Container();

        }
      },
    );
  }
}
