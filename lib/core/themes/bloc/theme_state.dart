part of 'theme_bloc.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

final class LightThemeActionState extends ThemeState {}

final class DarkThemeActionState extends ThemeState {}
