import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/create_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/enqueue_offline_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_state.dart';

class CreateProcedureBloc
    extends Bloc<CreateProcedureEvent, CreateProcedureState> {
  final CreateProcedureUseCase createProcedureUseCase;
  final EnqueueOfflineProcedureUseCase enqueueOfflineProcedureUseCase;
  final Logger _logger = Logger();

  CreateProcedureBloc(
    this.createProcedureUseCase,
    this.enqueueOfflineProcedureUseCase,
  ) : super(const BaseState<CreateProcedureResult>()) {
    on<SubmitCreateProcedureEvent>(_onSubmitCreateProcedure);
    on<ResetCreateProcedureEvent>(_onResetCreateProcedure);
  }

  Future<void> _onSubmitCreateProcedure(
    SubmitCreateProcedureEvent event,
    Emitter<CreateProcedureState> emit,
  ) async {
    emit(state.loading());

    final result = await createProcedureUseCase(event.parameters);

    await result.fold(
      (failure) async {
        if (failure is NoInternetFailure) {
          _logger.i("No connectivity — queueing procedure offline");
          final queued = await enqueueOfflineProcedureUseCase(
            event.parameters,
          );
          queued.fold(
            (queueFailure) {
              _logger.e(
                "Failed to queue offline procedure: ${queueFailure.message}",
              );
              emit(state.error(queueFailure));
            },
            (pending) {
              emit(
                state.successNotNull(
                  CreateProcedureResult(
                    // Use the enqueued parameters, not the original submitted
                    // ones — EnqueueOfflineProcedureUseCase corrects
                    // isOffline/requestLiveCoSign for a queued item.
                    procedure: _placeholderProcedure(
                      pending.parameters,
                      pending.localId,
                    ),
                    queuedOffline: true,
                  ),
                ),
              );
            },
          );
          return;
        }
        _logger.e("Failed to create procedure: ${failure.message}");
        emit(state.error(failure));
      },
      (createResult) async {
        _logger.i(
          "Procedure created (liveCoSign: ${createResult.requiresLiveCoSign})",
        );
        emit(state.successNotNull(createResult));
      },
    );
  }

  Future<void> _onResetCreateProcedure(
    ResetCreateProcedureEvent event,
    Emitter<CreateProcedureState> emit,
  ) async {
    emit(const BaseState<CreateProcedureResult>());
  }

  /// A local stand-in for the server-confirmed `Procedure` a queued item
  /// will eventually become once `ProcedureSyncService` submits it.
  Procedure _placeholderProcedure(
    CreateProcedureParameters parameters,
    String localId,
  ) {
    return Procedure(
      id: 'local-$localId',
      status: 'Pending',
      patientName: parameters.patientName,
      procedureDate: parameters.procedureDate,
      notes: parameters.notes,
      isOffline: parameters.isOffline,
      isEmergency: parameters.isEmergency,
      hospitalId: parameters.hospitalId,
      procedureTypeId: parameters.procedureTypeId,
      supervisorId: parameters.supervisorId,
    );
  }
}
