part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

final class TextChanged extends SearchEvent {
  const TextChanged({required this.text});

  final String text;

  @override
  List<Object> get props => [text];

   @override
  String toString() => 'TextChanged { text: $text }';
}



