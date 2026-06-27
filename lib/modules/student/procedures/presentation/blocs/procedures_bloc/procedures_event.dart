import 'package:equatable/equatable.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';

sealed class ProceduresEvent extends Equatable {
  const ProceduresEvent();
}

class FetchProceduresEvent extends ProceduresEvent {
  final ListProceduresParameters parameters;

  const FetchProceduresEvent(this.parameters);

  @override
  List<Object?> get props => [parameters];
}

class FilterProceduresByStatusEvent extends ProceduresEvent {
  final String status;

  const FilterProceduresByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}
