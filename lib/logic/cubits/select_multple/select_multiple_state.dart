part of 'select_multiple_cubit.dart';

sealed class SelectMultipleState extends Equatable {
  const SelectMultipleState();

  @override
  List<Object> get props => [];
}

final class SelectMultipleInitial extends SelectMultipleState {}

final class SelectMultipleLoading extends SelectMultipleState {}

final class SelectMultipleError extends SelectMultipleState {}

final class SelectMultipleActivated extends SelectMultipleState {
  final ListItem initiallySelectedItem;
  final List<ListItem> items;

  const SelectMultipleActivated({required this.initiallySelectedItem, required this.items});

  @override
  List<Object> get props => [initiallySelectedItem, items];
}

final class SelectMultipleActionState extends SelectMultipleState {}

final class SelectMultipleActionLoading extends SelectMultipleActionState {}

final class SelectMultipleActionSuccess extends SelectMultipleActionState {}

final class SelectMultipleActionError extends SelectMultipleActionState {
  SelectMultipleActionError();
}
