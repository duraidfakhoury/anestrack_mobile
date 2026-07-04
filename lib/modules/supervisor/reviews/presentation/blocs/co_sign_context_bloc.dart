import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/co_sign_context.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/get_co_sign_context_usecase.dart';

abstract class CoSignContextEvent {}

class FetchCoSignContextEvent extends CoSignContextEvent {
  final String coSignCode;
  FetchCoSignContextEvent(this.coSignCode);
}

class ResetCoSignContextEvent extends CoSignContextEvent {}

typedef CoSignContextState = BaseState<CoSignContext>;

/// Supervisor — preview who/what a co-sign code refers to before tapping.
class CoSignContextBloc extends Bloc<CoSignContextEvent, CoSignContextState> {
  final GetCoSignContextUseCase useCase;
  final Logger _logger = Logger();

  CoSignContextBloc(this.useCase) : super(const BaseState<CoSignContext>()) {
    on<FetchCoSignContextEvent>(_onFetch);
    on<ResetCoSignContextEvent>((_, emit) => emit(const BaseState<CoSignContext>()));
  }

  Future<void> _onFetch(
    FetchCoSignContextEvent event,
    Emitter<CoSignContextState> emit,
  ) async {
    emit(state.loading());
    final result = await useCase(event.coSignCode);
    result.fold(
      (failure) {
        _logger.e('Failed to fetch co-sign context: ${failure.message}');
        emit(state.error(failure));
      },
      (context) => emit(state.successNotNull(context)),
    );
  }
}
