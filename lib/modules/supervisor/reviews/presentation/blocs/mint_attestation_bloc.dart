import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/entities/offline_attestation.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/usecases/mint_offline_attestation_usecase.dart';

abstract class MintAttestationEvent {}

class GenerateAttestationEvent extends MintAttestationEvent {
  final String? note;
  GenerateAttestationEvent({this.note});
}

class ResetMintAttestationEvent extends MintAttestationEvent {}

typedef MintAttestationState = BaseState<OfflineAttestation>;

/// Supervisor — "Witness a procedure": mints and persists a bedside
/// attestation, entirely offline. The screen must wait for this to succeed
/// before rendering the QR (spec rule §8.3).
class MintAttestationBloc extends Bloc<MintAttestationEvent, MintAttestationState> {
  final MintOfflineAttestationUseCase useCase;
  final Logger _logger = Logger();

  MintAttestationBloc(this.useCase)
    : super(const BaseState<OfflineAttestation>()) {
    on<GenerateAttestationEvent>(_onGenerate);
    on<ResetMintAttestationEvent>(
      (_, emit) => emit(const BaseState<OfflineAttestation>()),
    );
  }

  Future<void> _onGenerate(
    GenerateAttestationEvent event,
    Emitter<MintAttestationState> emit,
  ) async {
    emit(state.loading());
    final result = await useCase(note: event.note);
    result.fold(
      (failure) {
        _logger.e('Failed to mint offline attestation: ${failure.message}');
        emit(state.error(failure));
      },
      (attestation) => emit(state.successNotNull(attestation)),
    );
  }
}
