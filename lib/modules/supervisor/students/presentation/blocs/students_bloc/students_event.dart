part of 'students_bloc.dart';

abstract class StudentsEvent {}

class FetchStudentsEvent extends StudentsEvent {
  final ListStudentsParameters parameters;

  FetchStudentsEvent([this.parameters = const ListStudentsParameters()]);
}
