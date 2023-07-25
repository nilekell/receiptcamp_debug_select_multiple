import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'search_event.dart';
part 'search_state.dart';

const _duration = Duration(milliseconds: 300);

// delays the calling of _onTextChanged() by a set duration. This reduces unnecessary
// database calls in _fetchSuggestions() as _onTextChanged() is called whenever the contents of the [query] changes in CustomSearchDelegate
EventTransformer<SearchEvent> debounce<SearchEvent>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required this.databaseRepository}) : super(SearchInitial()) {
    on<SearchInitialEvent>(_initial);
    on<TextChanged>(_onTextChanged, transformer: debounce(_duration));
    on<FetchSuggestions>(_fetchSuggestions);
    on<FetchResults>(_fetchResults);
  }
  final DatabaseRepository databaseRepository;

  FutureOr<void> _initial(SearchInitialEvent event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }

  FutureOr<void> _onTextChanged(TextChanged event, Emitter<SearchState> emit) async {
    emit(SearchStateLoading());
    final searchTerm = event.text;

    if (searchTerm.isEmpty) {
      emit(SearchStateNoQuery());
      return;
    } 

   add(FetchSuggestions(queryText: searchTerm));
  }

  FutureOr<void> _fetchSuggestions(FetchSuggestions event, Emitter<SearchState> emit) async {
    emit(SearchStateLoading());
    try {
      final receipts = await databaseRepository.getSuggestedReceiptsByTags(event.queryText);
      
      if (receipts.isEmpty) {
        emit(SearchStateEmpty());
        return;
      }

      emit(SearchStateSuccess(receipts));

    } catch (e) {
      emit(SearchStateError(e.toString()));
    } 
  }

  FutureOr<void> _fetchResults(FetchResults event, Emitter<SearchState> emit) async {
    emit(SearchStateLoading());
    try {
      final receipts = await databaseRepository.getFinalReceiptsByTags(event.queryText);
      
      if (receipts.isEmpty) {
        emit(SearchStateEmpty());
        return;
      }

      emit(SearchStateSuccess(receipts));

    } catch (e) {
      emit(SearchStateError(e.toString()));
    } 
  }
}
