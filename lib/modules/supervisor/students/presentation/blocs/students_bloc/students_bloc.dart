import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/entities/student.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/parameters/list_students_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/usecases/list_students_usecase.dart';

part 'students_event.dart';
part 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final ListStudentsUseCase listStudentsUseCase;
  final Logger _logger = Logger();

  static const _pageSize = 20;

  List<Student> _allStudents = [];
  ListStudentsParameters _baseParameters = const ListStudentsParameters();
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  StudentsBloc(this.listStudentsUseCase)
    : super(const BaseState<List<Student>>()) {
    on<FetchStudentsEvent>(_onFetchStudents);
    on<RefreshStudentsEvent>(_onRefresh);
    on<LoadMoreStudentsEvent>(_onLoadMore);
  }

  Future<void> _onFetchStudents(
    FetchStudentsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    _baseParameters = event.parameters;
    await _fetchFirstPage(emit);
  }

  Future<void> _onRefresh(
    RefreshStudentsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    await _fetchFirstPage(emit);
  }

  Future<void> _fetchFirstPage(Emitter<StudentsState> emit) async {
    emit(state.loading());
    final result = await listStudentsUseCase(_pageParams(skip: 0));
    result.fold(
      (failure) {
        _logger.e('Failed to fetch students: ${failure.message}');
        emit(state.error(failure));
      },
      (students) {
        _logger.i('Fetched ${students.length} students');
        _allStudents = students;
        _hasMore = students.length == _pageSize;
        emit(state.successNotNull(_allStudents));
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreStudentsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    if (_isLoadingMore || !_hasMore || !state.isSuccess) return;
    _isLoadingMore = true;

    final result = await listStudentsUseCase(
      _pageParams(skip: _allStudents.length),
    );

    result.fold(
      (failure) => _logger.e('Failed to load more students: ${failure.message}'),
      (students) {
        _allStudents = [..._allStudents, ...students];
        _hasMore = students.length == _pageSize;
        emit(state.successNotNull(_allStudents));
      },
    );

    _isLoadingMore = false;
  }

  ListStudentsParameters _pageParams({required int skip}) =>
      ListStudentsParameters(
        yearCode: _baseParameters.yearCode,
        limit: _pageSize,
        skip: skip,
      );
}
