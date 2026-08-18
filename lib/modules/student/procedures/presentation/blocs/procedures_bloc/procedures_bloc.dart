import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_state.dart';

class ProceduresBloc extends Bloc<ProceduresEvent, ProceduresState> {
  final ListProceduresUseCase listProceduresUseCase;
  final Logger _logger = Logger();

  static const _pageSize = 20;

  List<Procedure> _allProcedures = [];
  ListProceduresParameters _baseParameters = const ListProceduresParameters();
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  ProceduresBloc(this.listProceduresUseCase)
    : super(const BaseState<List<Procedure>>()) {
    on<FetchProceduresEvent>(_onFetchProcedures);
    on<FilterProceduresByStatusEvent>(_onFilterByStatus);
    on<RefreshProceduresEvent>(_onRefresh);
    on<LoadMoreProceduresEvent>(_onLoadMore);
  }

  Future<void> _onFetchProcedures(
    FetchProceduresEvent event,
    Emitter<ProceduresState> emit,
  ) async {
    _baseParameters = event.parameters;
    await _fetchFirstPage(emit);
  }

  Future<void> _onFilterByStatus(
    FilterProceduresByStatusEvent event,
    Emitter<ProceduresState> emit,
  ) async {
    _baseParameters = ListProceduresParameters(
      status: event.status == 'all' ? null : event.status,
      studentId: _baseParameters.studentId,
      assuranceLevel: _baseParameters.assuranceLevel,
      flag: _baseParameters.flag,
      worstFirst: _baseParameters.worstFirst,
    );
    await _fetchFirstPage(emit);
  }

  Future<void> _onRefresh(
    RefreshProceduresEvent event,
    Emitter<ProceduresState> emit,
  ) async {
    await _fetchFirstPage(emit);
  }

  Future<void> _fetchFirstPage(Emitter<ProceduresState> emit) async {
    emit(state.loading());

    final result = await listProceduresUseCase(_pageParams(skip: 0));

    result.fold(
      (failure) {
        _logger.e("Failed to fetch procedures: ${failure.message}");
        emit(state.error(failure));
      },
      (procedures) {
        _logger.i("Successfully fetched ${procedures.length} procedures");
        _allProcedures = procedures;
        _hasMore = procedures.length == _pageSize;
        emit(state.successNotNull(_allProcedures));
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreProceduresEvent event,
    Emitter<ProceduresState> emit,
  ) async {
    if (_isLoadingMore || !_hasMore || !state.isSuccess) return;
    _isLoadingMore = true;

    final result = await listProceduresUseCase(
      _pageParams(skip: _allProcedures.length),
    );

    result.fold(
      (failure) {
        _logger.e("Failed to load more procedures: ${failure.message}");
      },
      (procedures) {
        _logger.i("Loaded ${procedures.length} more procedures");
        _allProcedures = [..._allProcedures, ...procedures];
        _hasMore = procedures.length == _pageSize;
        emit(state.successNotNull(_allProcedures));
      },
    );

    _isLoadingMore = false;
  }

  ListProceduresParameters _pageParams({required int skip}) =>
      ListProceduresParameters(
        status: _baseParameters.status,
        studentId: _baseParameters.studentId,
        assuranceLevel: _baseParameters.assuranceLevel,
        flag: _baseParameters.flag,
        worstFirst: _baseParameters.worstFirst,
        limit: _pageSize,
        skip: skip,
      );
}
