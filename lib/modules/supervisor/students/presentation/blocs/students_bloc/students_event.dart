part of 'students_bloc.dart';

abstract class StudentsEvent {}

class FetchStudentsEvent extends StudentsEvent {
  final ListStudentsParameters parameters;

  FetchStudentsEvent([this.parameters = const ListStudentsParameters()]);
}

/// Re-fetches page 1 with whatever filter is currently active.
class RefreshStudentsEvent extends StudentsEvent {}

/// Fetches the next page and appends it to the currently loaded list.
class LoadMoreStudentsEvent extends StudentsEvent {}
