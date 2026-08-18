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

/// Re-fetches page 1 with whatever filter is currently active, e.g. after
/// pull-to-refresh or after a new procedure was submitted elsewhere.
class RefreshProceduresEvent extends ProceduresEvent {
  const RefreshProceduresEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the next page and appends it to the currently loaded list.
class LoadMoreProceduresEvent extends ProceduresEvent {
  const LoadMoreProceduresEvent();

  @override
  List<Object?> get props => [];
}
