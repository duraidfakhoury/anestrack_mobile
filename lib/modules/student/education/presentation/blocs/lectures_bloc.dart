import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/list_lectures_usecase.dart';

abstract class LecturesEvent {}

class FetchLecturesEvent extends LecturesEvent {}

typedef LecturesState = BaseState<List<Lecture>>;

class LecturesBloc extends Bloc<LecturesEvent, LecturesState> {
  final ListLecturesUseCase listUseCase;

  LecturesBloc(this.listUseCase) : super(const BaseState<List<Lecture>>()) {
    on<FetchLecturesEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchLecturesEvent event,
    Emitter<LecturesState> emit,
  ) async {
    emit(state.loading());
    final result = await listUseCase();
    result.fold(
      (failure) => emit(state.error(failure)),
      (items) => emit(state.successNotNull(items)),
    );
  }
}
