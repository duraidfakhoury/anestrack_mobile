import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/create_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/enqueue_offline_cosigned_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/enqueue_offline_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_state.dart';

class CreateProcedureBloc
    extends Bloc<CreateProcedureEvent, CreateProcedureState> {
  final CreateProcedureUseCase createProcedureUseCase;
  final EnqueueOfflineProcedureUseCase enqueueOfflineProcedureUseCase;
  final EnqueueOfflineCoSignedProcedureUseCase
  enqueueOfflineCoSignedProcedureUseCase;
  final Logger _logger = Logger();

  CreateProcedureBloc(
    this.createProcedureUseCase,
    this.enqueueOfflineProcedureUseCase,
    this.enqueueOfflineCoSignedProcedureUseCase,
  ) : super(const BaseState<CreateProcedureResult>()) {
    on<SubmitCreateProcedureEvent>(_onSubmitCreateProcedure);
    on<QueuePlainOfflineProcedureEvent>(_onQueuePlainOffline);
    on<QueueCoSignedOfflineProcedureEvent>(_onQueueCoSignedOffline);
    on<ResetCreateProcedureEvent>(_onResetCreateProcedure);
  }

  Future<void> _onSubmitCreateProcedure(
    SubmitCreateProcedureEvent event,
    Emitter<CreateProcedureState> emit,
  ) async {
    emit(state.loading());

    final result = await createProcedureUseCase(event.parameters);

    result.fold(
      (failure) {
        if (failure is NoInternetFailure) {
          // Don't auto-queue — the UI must first ask whether the student
          // wants to attach a supervisor's bedside code (offline co-sign)
          // or save without one, per `integration-mobile-offline-cosign.md`
          // §5. Nothing has been persisted locally yet at this point.
          _logger.i(
            "No connectivity — awaiting offline co-sign decision from the UI",
          );
          emit(
            state.successNotNull(
              CreateProcedureResult(
                procedure: _placeholderProcedure(
                  event.parameters,
                  'offline-pending',
                ),
                offlineNeedsDecision: true,
              ),
            ),
          );
          return;
        }
        _logger.e("Failed to create procedure: ${failure.message}");
        emit(state.error(failure));
      },
      (createResult) {
        _logger.i(
          "Procedure created (liveCoSign: ${createResult.requiresLiveCoSign})",
        );
        emit(state.successNotNull(createResult));
      },
    );
  }

  Future<void> _onQueuePlainOffline(
    QueuePlainOfflineProcedureEvent event,
    Emitter<CreateProcedureState> emit,
  ) async {
    emit(state.loading());
    final queued = await enqueueOfflineProcedureUseCase(event.parameters);
    queued.fold(
      (failure) {
        _logger.e("Failed to queue offline procedure: ${failure.message}");
        emit(state.error(failure));
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
  }

  Future<void> _onQueueCoSignedOffline(
    QueueCoSignedOfflineProcedureEvent event,
    Emitter<CreateProcedureState> emit,
  ) async {
    emit(state.loading());
    final queued = await enqueueOfflineCoSignedProcedureUseCase(
      form: event.parameters,
      scannedAttestation: event.scannedAttestation,
    );
    queued.fold(
      (failure) {
        _logger.e(
          "Failed to queue offline co-signed procedure: ${failure.message}",
        );
        emit(state.error(failure));
      },
      (queuedItem) {
        emit(
          state.successNotNull(
            CreateProcedureResult(
              procedure: _placeholderProcedure(
                event.parameters,
                queuedItem.localId,
              ),
              queuedOffline: true,
              queuedCoSigned: true,
            ),
          ),
        );
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
  /// will eventually become once the relevant sync service submits it.
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
      procedureTypeId: parameters.procedureTypeIds.isNotEmpty
          ? parameters.procedureTypeIds.first
          : null,
      supervisorId: parameters.supervisorId,
    );
  }
}
