import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/blocs/search/search_bloc.dart';
import 'package:receiptcamp/models/receipt.dart';
import 'package:receiptcamp/presentation/screens/image_view.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class CustomSearchDelegate extends SearchDelegate {
  final SearchBloc searchBloc;

  CustomSearchDelegate({required this.searchBloc}) : super();

  final startSearchingText = const Text(
    'Start searching with any words on a receipt',
    style: TextStyle(color: Color(primaryGrey), fontSize: 17),
  );
  final noResultsText = const Text(
    "Sorry, we couldn't find any results",
    style: TextStyle(color: Color(primaryGrey), fontSize: 17),
  );
  final errorText =
      const Text('Sorry, an unexpected error occured, please try again');

  // @override
  // String get searchFieldLabel => 'Search';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(backgroundColor: Color(primaryDarkBlue)),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white),
        border: InputBorder.none, // This gets rid of the underline
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
    ));
  }

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
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // third overridden method to show the querying process at the runtime
  // method is called when the user submits a query in the keyboard
  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        switch (state) {
          case SearchInitial():
            return Container();
          case SearchStateLoading():
            return const Center(child: CircularProgressIndicator());
          case SearchStateNoQuery():
            return Center(child: startSearchingText);
          case SearchStateEmpty():
            return Center(child: noResultsText);
          case SearchStateSuccess():
            return Scrollbar(
                child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final receipt = state.items[index];
                      return ReceiptSearchTile(receipt: receipt);
                    }));
          case SearchStateError():
            return Center(child: errorText);
          default:
            return Container();
        }
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
          case SearchStateNoQuery():
            return Center(child: startSearchingText);
          case SearchStateEmpty():
            return Center(child: noResultsText);
          case SearchStateSuccess():
            return Scrollbar(
                child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final receipt = state.items[index];
                      return ReceiptSearchTile(receipt: receipt);
                    }));
          case SearchStateError():
            return Center(child: errorText);
          default:
            return Container();
        }
      },
    );
  }
}

class ReceiptSearchTile extends StatelessWidget {
  final Receipt receipt;

  const ReceiptSearchTile({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Transform.scale(
            scale: 1.4,
            child: Image.asset('assets/receipt.png', colorBlendMode: BlendMode.srcIn, color: const Color(primaryGrey).withOpacity(0.5),),
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .push(SlidingImageTransitionRoute(receipt: receipt));
        },
        title: Text(receipt.name.split('.').first));
  }
}
