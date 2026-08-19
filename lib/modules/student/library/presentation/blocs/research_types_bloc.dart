import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_type.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/list_research_types_usecase.dart';

abstract class ResearchTypesEvent {}

class FetchResearchTypesEvent extends ResearchTypesEvent {}

typedef ResearchTypesState = BaseState<List<ResearchType>>;

class ResearchTypesBloc extends Bloc<ResearchTypesEvent, ResearchTypesState> {
  final ListResearchTypesUseCase listResearchTypesUseCase;
  final Logger _logger = Logger();

  ResearchTypesBloc(this.listResearchTypesUseCase)
    : super(const BaseState<List<ResearchType>>()) {
    on<FetchResearchTypesEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchResearchTypesEvent event,
    Emitter<ResearchTypesState> emit,
  ) async {
    emit(state.loading());
    final result = await listResearchTypesUseCase();
    result.fold(
      (failure) {
        _logger.e('Failed to fetch research types: ${failure.message}');
        emit(state.error(failure));
      },
      (types) => emit(state.successNotNull(types)),
    );
  }
}
