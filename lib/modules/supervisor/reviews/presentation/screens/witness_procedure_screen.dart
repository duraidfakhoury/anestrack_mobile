import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_qr_payload.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/domain/entities/offline_attestation.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/mint_attestation_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _indigo = Color(0xFF4338CA);
const _indigoLight = Color(0xFF4F46E5);

/// Supervisor — "Witness a procedure" (offline co-sign, bedside half). Mints
/// a `localId`/`code`/`witnessedAt` triple, persists it to the local outbox,
/// and shows it as a QR for the student to scan — entirely offline, no
/// server round trip. See `integration-mobile-offline-cosign.md` §4.
///
/// Deliberately has NO copy-code button, NO share button, and NO timeout:
/// unlike the online live co-sign flow (`CoSignHandoffScreen`), this QR
/// carries a secret that must only ever travel by camera (spec rule §8.1),
/// and there's no server-side expiry racing the bedside interaction — only
/// the *upload* has a 72-hour window (spec §4).
class WitnessProcedureScreen extends StatefulWidget {
  const WitnessProcedureScreen({super.key});

  @override
  State<WitnessProcedureScreen> createState() =>
      _WitnessProcedureScreenState();
}

class _WitnessProcedureScreenState extends State<WitnessProcedureScreen> {
  late final MintAttestationBloc _bloc;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<MintAttestationBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    _noteController.dispose();
    super.dispose();
  }

  void _generate() {
    final note = _noteController.text.trim();
    _bloc.add(GenerateAttestationEvent(note: note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: BlocBuilder<MintAttestationBloc, MintAttestationState>(
        bloc: _bloc,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: state.data != null
                      ? _buildQrCard(state.data!)
                      : _buildGenerateForm(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 22, right: 20, left: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_indigoLight, _indigo],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowRight, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.offline_cosign_witness_title.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.offline_cosign_witness_subtitle.tr(),
                  style: const TextStyle(
                    color: Color(0xFFE0E7FF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateForm(MintAttestationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3EAED)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.offline_cosign_witness_note_label.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: LocaleKeys.offline_cosign_witness_note_hint.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (state.isError)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              LocaleKeys.offline_cosign_witness_mint_error.tr(),
              style: const TextStyle(color: Color(0xFFC1483F), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ElevatedButton.icon(
          onPressed: state.isLoading ? null : _generate,
          style: ElevatedButton.styleFrom(
            backgroundColor: _indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(LucideIcons.qrCode, size: 18),
          label: Text(LocaleKeys.offline_cosign_witness_generate_button.tr()),
        ),
      ],
    );
  }

  Widget _buildQrCard(OfflineAttestation attestation) {
    final payload = OfflineCoSignQrPayload(
      v: OfflineCoSignQrPayload.supportedVersion,
      localId: attestation.localId,
      code: attestation.code,
      witnessedAt: attestation.witnessedAt,
    ).encode();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3EAED)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                LocaleKeys.offline_cosign_witness_qr_label.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5B6B73)),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: payload,
                size: 220,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _indigo,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: _indigo,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFECEAF9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.info, color: _indigo, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  LocaleKeys.offline_cosign_witness_qr_instructions.tr(),
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF3B3470)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => context.pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: _indigo,
            side: const BorderSide(color: Color(0xFFD6D9F5)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(LocaleKeys.offline_cosign_witness_done_button.tr()),
        ),
      ],
    );
  }
}
