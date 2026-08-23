import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_status.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/get_offline_cosign_status_usecase.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_event.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_state.dart';

/// Shared by both roles — "did my scan/attestation work" (spec §6.3). A
/// singleton so both `OfflineCosignedProcedureSyncService` and
/// `OfflineAttestationSyncService` can poke a refresh after a sync run.
class OfflineCoSignStatusBloc
    extends Bloc<OfflineCoSignStatusEvent, OfflineCoSignStatusState> {
  final GetOfflineCoSignStatusUseCase getOfflineCoSignStatusUseCase;
  final Logger _logger = Logger();

  OfflineCoSignStatusBloc(this.getOfflineCoSignStatusUseCase)
    : super(const BaseState<OfflineCoSignStatus>()) {
    on<FetchOfflineCoSignStatusEvent>(_onFetch);
    on<RefreshOfflineCoSignStatusEvent>(_onFetch);
  }

  Future<void> _onFetch(
    OfflineCoSignStatusEvent event,
    Emitter<OfflineCoSignStatusState> emit,
  ) async {
    emit(state.loading());

    final result = await getOfflineCoSignStatusUseCase();

    result.fold(
      (failure) {
        _logger.e("Failed to fetch offline co-sign status: ${failure.message}");
        emit(state.error(failure));
      },
      (status) {
        emit(state.successNotNull(status));
      },
    );
  }
}
