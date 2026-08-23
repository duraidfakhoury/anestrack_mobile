import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_bloc.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_event.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/blocs/offline_cosign_status_bloc/offline_cosign_status_state.dart';
import 'package:anestrack_mobile/modules/common/support/presentation/routes/support_route.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_status.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _teal = Color(0xFF0D9488);
const _cyan = Color(0xFF0891B2);
const _indigo = Color(0xFF4338CA);
const _indigoLight = Color(0xFF4F46E5);

/// Shared by both roles — answers "I scanned the code / generated the code
/// — did it work?" (spec §6.3). Branches entirely on `CacheService().userRole`:
/// a student sees their `claims[]`, a supervisor their `attestations[]` — the
/// backend response is already filtered to the caller, so no client-side
/// filtering is needed, just which list to render.
class OfflineCoSignStatusScreen extends StatefulWidget {
  const OfflineCoSignStatusScreen({super.key});

  @override
  State<OfflineCoSignStatusScreen> createState() =>
      _OfflineCoSignStatusScreenState();
}

class _OfflineCoSignStatusScreenState extends State<OfflineCoSignStatusScreen> {
  late final OfflineCoSignStatusBloc _bloc;
  bool get _isStudent => CacheService().userRole == 'Student';

  @override
  void initState() {
    super.initState();
    _bloc = sl<OfflineCoSignStatusBloc>()
      ..add(const FetchOfflineCoSignStatusEvent());
  }

  Color get _primary => _isStudent ? _teal : _indigo;
  Color get _secondary => _isStudent ? _cyan : _indigoLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: BlocBuilder<OfflineCoSignStatusBloc, OfflineCoSignStatusState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.isError) {
                  return _ErrorView(
                    message: state.errorMessage,
                    onRetry: () => _bloc.add(
                      const RefreshOfflineCoSignStatusEvent(),
                    ),
                  );
                }
                final data = state.data ?? const OfflineCoSignStatus();
                return RefreshIndicator(
                  onRefresh: () async => _bloc.add(
                    const RefreshOfflineCoSignStatusEvent(),
                  ),
                  child: _isStudent
                      ? _buildClaimsList(data.claims)
                      : _buildAttestationsList(data.attestations),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 22, right: 20, left: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_secondary, _primary],
        ),
        borderRadius: const BorderRadius.only(
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
          Text(
            LocaleKeys.offline_cosign_status_title.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsList(List<OfflineCoSignClaim> claims) {
    if (claims.isEmpty) {
      return _EmptyView(
        message: LocaleKeys.offline_cosign_status_claims_empty.tr(),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: claims.length,
      itemBuilder: (context, idx) => _ClaimCard(claim: claims[idx]),
    );
  }

  Widget _buildAttestationsList(List<OfflineCoSignAttestation> attestations) {
    if (attestations.isEmpty) {
      return _EmptyView(
        message: LocaleKeys.offline_cosign_status_attestations_empty.tr(),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: attestations.length,
      itemBuilder: (context, idx) =>
          _AttestationCard(attestation: attestations[idx]),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  final OfflineCoSignClaim claim;

  const _ClaimCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final Color bg;
    late final String label;
    if (claim.isMatched) {
      color = const Color(0xFF2E9E6B);
      bg = const Color(0xFFE7F5EE);
      label = LocaleKeys.offline_cosign_status_claim_matched.tr();
    } else if (claim.isExpired) {
      color = const Color(0xFFC1483F);
      bg = const Color(0xFFFDEDEC);
      label = LocaleKeys.offline_cosign_status_claim_expired.tr();
    } else {
      color = const Color(0xFFD98C2B);
      bg = const Color(0xFFFDF4E7);
      label = LocaleKeys.offline_cosign_status_claim_awaiting.tr();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (claim.capturedAt ?? '').split('T').first,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (claim.isMatched && claim.clockSkewMinutes != null) ...[
            const SizedBox(height: 8),
            Text(
              LocaleKeys.offline_cosign_scan_clock_skew_warning.tr(
                args: [claim.clockSkewMinutes.toString()],
              ),
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttestationCard extends StatelessWidget {
  final OfflineCoSignAttestation attestation;

  const _AttestationCard({required this.attestation});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final Color bg;
    late final String label;
    if (attestation.matched) {
      color = const Color(0xFF2E9E6B);
      bg = const Color(0xFFE7F5EE);
      label = attestation.claimedByName != null
          ? LocaleKeys.offline_cosign_status_attestation_matched.tr(
              args: [attestation.claimedByName!],
            )
          : LocaleKeys.offline_cosign_status_claim_matched.tr();
    } else if (attestation.expired) {
      color = const Color(0xFFC1483F);
      bg = const Color(0xFFFDEDEC);
      label = LocaleKeys.offline_cosign_status_attestation_expired.tr();
    } else {
      color = const Color(0xFF6A5ACD);
      bg = const Color(0xFFECEAF9);
      label = LocaleKeys.offline_cosign_status_attestation_pending.tr();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  attestation.witnessedAt.split('T').first,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (attestation.note != null && attestation.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              attestation.note!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 10),
          // Deliberate per spec §9: the supervisor learns nothing about who
          // scanned the QR at the bedside beyond the claimant's name — this
          // is the only channel to flag a code that reached the wrong
          // person, so it must always be visible, not just on a mismatch.
          InkWell(
            onTap: () => context.push(SupportRoute.name),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.shieldAlert,
                  size: 13,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 4),
                Text(
                  LocaleKeys.offline_cosign_status_contact_admin.tr(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF9CA3AF),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.qrCode, size: 48, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 48,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
