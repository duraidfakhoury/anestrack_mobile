import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/parameters/create_complaint_parameters.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/usecases/create_complaint_usecase.dart';

abstract class ComplaintEvent {}

class SubmitComplaintEvent extends ComplaintEvent {
  final CreateComplaintParameters parameters;
  SubmitComplaintEvent(this.parameters);
}

class ResetComplaintEvent extends ComplaintEvent {}

typedef ComplaintState = BaseState<Unit>;

/// Student — submit a confidential complaint (`createComplaint`).
class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final CreateComplaintUseCase useCase;
  final Logger _logger = Logger();

  ComplaintBloc(this.useCase) : super(const BaseState<Unit>()) {
    on<SubmitComplaintEvent>(_onSubmit);
    on<ResetComplaintEvent>((_, emit) => emit(const BaseState<Unit>()));
  }

  Future<void> _onSubmit(
    SubmitComplaintEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(state.loading());
    final result = await useCase(event.parameters);
    result.fold(
      (failure) {
        _logger.e('Failed to submit complaint: ${failure.message}');
        emit(state.error(failure));
      },
      (_) => emit(state.successNotNull(unit)),
    );
  }
}
