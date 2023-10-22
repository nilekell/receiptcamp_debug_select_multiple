part of 'select_multiple_cubit.dart';

sealed class SelectMultipleState extends Equatable {
  const SelectMultipleState();

  @override
  List<Object> get props => [];
}

final class SelectMultipleInitial extends SelectMultipleState {}

final class SelectMultipleLoading extends SelectMultipleState {}

final class SelectMultipleActivated extends SelectMultipleState {
  final Object initiallySelectedItem;
  final List<Object> items;
  final Folder selectedItemParentFolder;

  const SelectMultipleActivated({required this.initiallySelectedItem, required this.items, required this.selectedItemParentFolder});

  @override
  List<Object> get props => [initiallySelectedItem, items];
}

final class SelectMultipleError extends SelectMultipleState {}
