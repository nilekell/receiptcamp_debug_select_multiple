import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'search_event.dart';
part 'search_state.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required this.databaseRepository}) : super(SearchInitial()) {
    on<TextChanged>(_onTextChanged, transformer: debounce(_duration));
  }
  final DatabaseRepository databaseRepository;



  FutureOr<void> _onTextChanged(TextChanged event, Emitter<SearchState> emit) async {
    final searchTerm = event.text;

    if (searchTerm.isEmpty) return emit(SearchStateEmpty());

    emit(SearchStateLoading());

    try {
      // final results = await databaseRepository.search(searchTerm);
      // emit(SearchStateSuccess(results.items));
    } catch (error) {
      emit(const SearchStateError('something went wrong'));
    }
  }
}
