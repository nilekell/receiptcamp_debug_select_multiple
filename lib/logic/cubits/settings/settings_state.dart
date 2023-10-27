part of 'settings_cubit.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

final class SettingsInitial extends SettingsState {}

final class SettingsLoading extends SettingsState {}

final class SettingsError extends SettingsState {}

final class SettingsSuccess extends SettingsState {}

final class SettingsFileState extends SettingsSuccess {}

final class SettingsFileLoadingState extends SettingsFileState {}

final class SettingsFileLoadedState extends SettingsFileState {
  final File file;
  final Folder folder;

  SettingsFileLoadedState({required this.file, required this.folder});

  @override
  List<Object> get props => [file, folder];
}

final class SettingsFileErrorState extends SettingsFileState {}

