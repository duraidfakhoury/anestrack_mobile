import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';

sealed class CreateProcedureEvent extends Equatable {
  const CreateProcedureEvent();
}

class SubmitCreateProcedureEvent extends CreateProcedureEvent {
  final CreateProcedureParameters parameters;

  const SubmitCreateProcedureEvent(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

class ResetCreateProcedureEvent extends CreateProcedureEvent {
  const ResetCreateProcedureEvent();

  @override
  List<Object?> get props => [];
}
