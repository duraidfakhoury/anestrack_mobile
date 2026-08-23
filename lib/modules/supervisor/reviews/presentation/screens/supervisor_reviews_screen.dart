import 'package:anestrack_mobile/core/services/ble/supervisor_code_ble_scanner.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/confirm_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/confirm_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/live_co_sign_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/pending_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/routes/ble_debug_supervisor_route.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/routes/co_sign_scan_route.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/routes/witness_procedure_route.dart';
import 'package:anestrack_mobile/modules/common/offline_cosign_status/presentation/routes/offline_cosign_status_route.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/widgets/co_sign_code_sheet.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/widgets/evaluation_rating_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _indigo = Color(0xFF4338CA);
const _indigoLight = Color(0xFF4F46E5);

class SupervisorReviewsScreen extends StatefulWidget {
  const SupervisorReviewsScreen({super.key});

  @override
  State<SupervisorReviewsScreen> createState() =>
      _SupervisorReviewsScreenState();
}

class _SupervisorReviewsScreenState extends State<SupervisorReviewsScreen> {
  late final PendingBloc _pendingBloc;
  late final ConfirmActionBloc _confirmBloc;
  late final CoSignActionBloc _coSignBloc;
  late final LiveCoSignBloc _liveCoSignBloc;

  @override
  void initState() {
    super.initState();
    _pendingBloc = sl<PendingBloc>()..add(FetchPendingEvent());
    _confirmBloc = sl<ConfirmActionBloc>();
    _coSignBloc = sl<CoSignActionBloc>();
    _liveCoSignBloc = sl<LiveCoSignBloc>();
  }

  @override
  void dispose() {
    _pendingBloc.close();
    _confirmBloc.close();
    _coSignBloc.close();
    _liveCoSignBloc.close();
    super.dispose();
  }

  void _refresh() => _pendingBloc.add(FetchPendingEvent());

  void _toast(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  /// Rating step (`createEvaluation`) shown before a co-sign or a "Confirm"
  /// decision — not before "Reject", which isn't rating anything. Returns
  /// whether an evaluation was submitted (or wasn't needed).
  Future<bool> _evaluate(String procedureId) async {
    final rated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EvaluationRatingSheet(procedureId: procedureId),
    );
    return rated == true;
  }

  Future<void> _confirm(Procedure p, String decision) async {
    if (decision == 'Confirm') {
      if (!await _evaluate(p.id)) return;
      if (!mounted) return;
    }
    _confirmBloc.add(
      SubmitConfirmEvent(
        ConfirmProcedureParameters(id: p.id, decision: decision),
      ),
    );
  }

  /// Server-mediated fallback co-sign from the pending list (no proximity proof).
  Future<void> _coSignById(Procedure p) async {
    if (!await _evaluate(p.id)) return;
    if (!mounted) return;
    _coSignBloc.add(SubmitCoSignEvent(CoSignParameters(id: p.id)));
  }

  Future<void> _openCoSignSheet() async {
    final signed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CoSignCodeSheet(),
    );
    if (signed == true) {
      _toast('تم توقيع الإجراء — موثّق', const Color(0xFF2E9E6B));
      _refresh();
    }
  }

  Future<void> _openNearMeScan() async {
    final signed = await context.push<bool>(CoSignScanRoute.name);
    if (signed == true) {
      _toast(
        LocaleKeys.co_sign_co_signed_success.tr(),
        const Color(0xFF2E9E6B),
      );
      _refresh();
    }
  }

  /// Offline co-sign, bedside half — works with zero connectivity, unlike
  /// every other button on this screen. See `WitnessProcedureScreen`.
  void _openWitnessProcedure() {
    context.push(WitnessProcedureRoute.name);
  }

  void _openOfflineCoSignStatus() {
    context.push(OfflineCoSignStatusRoute.name);
  }

  /// A nearby student's co-sign code arrived over BLE (see [LiveCoSignBloc])
  /// — open the same confirmation sheet the QR flow uses, pre-filled, so the
  /// supervisor still has to tap to confirm before the co-sign API is
  /// called.
  Future<void> _onBleCodeDetected(StudentCodeDetection detection) async {
    final signed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoSignCodeSheet(
        initialCode: detection.coSignCode,
        proximityMethod: 'BLE',
        proximityExtra: {'rssi': detection.rssi},
      ),
    );
    _liveCoSignBloc.add(StudentCodeHandledEvent());
    if (!mounted) return;
    if (signed == true) {
      _toast('تم توقيع الإجراء — موثّق', const Color(0xFF2E9E6B));
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ConfirmActionBloc, ConfirmActionState>(
            bloc: _confirmBloc,
            listener: (context, state) {
              if (state.isSuccess && state.data != null) {
                final approved = state.data!.status == 'Approved';
                _toast(
                  approved ? 'تم تأكيد الإجراء' : 'تم رفض الإجراء',
                  approved ? const Color(0xFF2E9E6B) : const Color(0xFFC1483F),
                );
                _refresh();
              } else if (state.isError) {
                _toast('خطأ: ${state.errorMessage}', const Color(0xFFC1483F));
                _refresh();
              }
            },
          ),
          BlocListener<CoSignActionBloc, CoSignActionState>(
            bloc: _coSignBloc,
            listener: (context, state) {
              if (state.isSuccess && state.data != null) {
                _toast('تم توقيع الإجراء', const Color(0xFF2E9E6B));
                _refresh();
              } else if (state.isError) {
                _toast('خطأ: ${state.errorMessage}', const Color(0xFFC1483F));
                _refresh();
              }
            },
          ),
          BlocListener<LiveCoSignBloc, LiveCoSignState>(
            bloc: _liveCoSignBloc,
            listenWhen: (previous, current) =>
                previous.detectedCode != current.detectedCode,
            listener: (context, state) {
              final detection = state.detectedCode;
              if (detection != null) _onBleCodeDetected(detection);
            },
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildLiveCoSignToggle(),
            _buildCoSignByCodeButton(),
            _buildNearMeScanButton(),
            _buildWitnessProcedureButton(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCoSignToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: BlocBuilder<LiveCoSignBloc, LiveCoSignState>(
        bloc: _liveCoSignBloc,
        builder: (context, state) {
          final isOn = state.status == LiveCoSignStatus.on;
          final isStarting = state.status == LiveCoSignStatus.starting;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOn ? const Color(0xFFECEAF9) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isOn ? _indigo : const Color(0xFFD6D9F5),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOn ? _indigo : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOn ? LucideIcons.bluetooth : LucideIcons.bluetoothOff,
                    color: isOn ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.live_co_sign_title.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _liveCoSignSubtitle(state.status),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isStarting)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(
                    value: isOn,
                    activeThumbColor: _indigo,
                    onChanged: (value) =>
                        _liveCoSignBloc.add(ToggleLiveCoSignEvent(value)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _liveCoSignSubtitle(LiveCoSignStatus status) {
    switch (status) {
      case LiveCoSignStatus.on:
        return LocaleKeys.live_co_sign_subtitle_on.tr();
      case LiveCoSignStatus.starting:
        return LocaleKeys.live_co_sign_starting.tr();
      case LiveCoSignStatus.bluetoothUnavailable:
        return LocaleKeys.live_co_sign_bluetooth_unavailable.tr();
      case LiveCoSignStatus.permissionDenied:
        return LocaleKeys.live_co_sign_permission_denied.tr();
      case LiveCoSignStatus.error:
        return LocaleKeys.live_co_sign_error.tr();
      case LiveCoSignStatus.off:
        return LocaleKeys.live_co_sign_subtitle_off.tr();
    }
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مهام المراجعة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "التوقيعات والتأكيدات بانتظارك",
                  style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13),
                ),
              ],
            ),
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(LucideIcons.bug, color: Colors.white70),
              onPressed: () => context.push(BleDebugSupervisorRoute.name),
            ),
        ],
      ),
    );
  }

  Widget _buildCoSignByCodeButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: InkWell(
        onTap: _openCoSignSheet,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6D9F5)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAF9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.keyRound, color: _indigo),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "توقيع مباشر بالرمز",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "الطالب بجانبك — أدخل رمزه لتوقيع فوري",
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronLeft, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearMeScanButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: InkWell(
        onTap: _openNearMeScan,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6D9F5)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAF9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.qrCode, color: _indigo),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.co_sign_near_me_title.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocaleKeys.co_sign_near_me_subtitle.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronLeft, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWitnessProcedureButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: InkWell(
        onTap: _openWitnessProcedure,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6D9F5)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAF9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.wifiOff, color: _indigo),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.offline_cosign_witness_entry_title.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocaleKeys.offline_cosign_witness_entry_subtitle.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.listChecks,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                tooltip: LocaleKeys.offline_cosign_status_title.tr(),
                onPressed: _openOfflineCoSignStatus,
              ),
              const Icon(LucideIcons.chevronLeft, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<PendingBloc, PendingState>(
      bloc: _pendingBloc,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.isError) {
          return _ErrorView(onRetry: _refresh, message: state.errorMessage);
        }
        final items = state.data ?? [];
        if (items.isEmpty) return const _EmptyView();
        final groups = _groupBySession(items);
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: groups.length,
            itemBuilder: (context, idx) {
              final group = groups[idx];
              final primary = group.first;
              return _PendingCard(
                group: group,
                onConfirm: () => _confirm(primary, 'Confirm'),
                onReject: () => _confirm(primary, 'Reject'),
                onCoSign: () => _coSignById(primary),
              );
            },
          ),
        );
      },
    );
  }

  /// Multi-type procedures (`integration-mobile.md` §5) arrive as one row per
  /// type sharing a `sessionId` — a single bedside case must render (and be
  /// decided) as one card, not N duplicates. Deciding any one row without an
  /// explicit `ids` subset resolves the whole session server-side, so a
  /// per-row card would be actively misleading. Rows without a `sessionId`
  /// (or sharing one accidentally) fall back to their own single-item group.
  List<List<Procedure>> _groupBySession(List<Procedure> items) {
    final order = <String>[];
    final bySession = <String, List<Procedure>>{};
    for (final item in items) {
      final key = item.sessionId ?? item.id;
      if (!bySession.containsKey(key)) order.add(key);
      bySession.putIfAbsent(key, () => []).add(item);
    }
    return [for (final key in order) bySession[key]!];
  }
}

class _PendingCard extends StatelessWidget {
  final List<Procedure> group;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onCoSign;

  const _PendingCard({
    required this.group,
    required this.onConfirm,
    required this.onReject,
    required this.onCoSign,
  });

  Procedure get _primary => group.first;

  bool get _isMultiType => group.length > 1;

  String get _date =>
      (_primary.procedureDate ?? _primary.createdAt ?? '').split('T').first;

  bool get _isConfirmation => _primary.isPendingConfirmation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isMultiType)
                      _buildTypeChips()
                    else
                      _IconLabel(
                        icon: LucideIcons.stethoscope,
                        text: _primary.procedureTypeName ?? 'إجراء',
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        iconColor: const Color(0xFF6A5ACD),
                      ),
                    const SizedBox(height: 6),
                    _IconLabel(
                      icon: LucideIcons.user,
                      text: _primary.studentName ?? 'طالب',
                      textStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _IconLabel(
                      icon: LucideIcons.heartPulse,
                      text: _primary.patientName,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              _KindBadge(isConfirmation: _isConfirmation),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaChip(
                icon: LucideIcons.building2,
                text: _primary.hospitalName ?? '—',
              ),
              _MetaChip(icon: LucideIcons.calendar, text: _date),
              if (_primary.isEmergency)
                const _MetaChip(
                  icon: LucideIcons.triangleAlert,
                  text: 'طارئ',
                  color: Color(0xFFC1483F),
                ),
            ],
          ),
          if (_isMultiType) ...[
            const SizedBox(height: 8),
            Text(
              'قرار واحد يشمل كل الأنواع أعلاه (${group.length})',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ],
          const SizedBox(height: 14),
          if (_isConfirmation)
            _buildConfirmActions()
          else
            _buildCoSignAwaiting(),
        ],
      ),
    );
  }

  /// One case, several types — shown as a labeled chip row instead of the
  /// single bold name, since a single decision (confirm/reject/co-sign)
  /// resolves every type in the session at once.
  Widget _buildTypeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              LucideIcons.stethoscope,
              size: 14,
              color: Color(0xFF6A5ACD),
            ),
            const SizedBox(width: 6),
            Text(
              'حالة بعدة أنواع',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: group
              .map((p) => p.procedureTypeName ?? 'إجراء')
              .map(
                (name) => _MetaChip(
                  icon: LucideIcons.stethoscope,
                  text: name,
                  color: const Color(0xFF6A5ACD),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC1483F),
              side: const BorderSide(color: Color(0xFFF2CFCC)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(LucideIcons.x, size: 16),
            label: const Text('رفض'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E9E6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(LucideIcons.check, size: 16),
            label: const Text('تأكيد'),
          ),
        ),
      ],
    );
  }

  Widget _buildCoSignAwaiting() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.clock, size: 14, color: Color(0xFF6A5ACD)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'بانتظار توقيع مباشر. الأفضل استخدام رمز الطالب (موثّق).',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5B6B73)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCoSign,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6A5ACD),
                side: const BorderSide(color: Color(0xFFD6D3F0)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('توقيع بدون رمز (تأكيد فقط)'),
            ),
          ),
        ],
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  final bool isConfirmation;

  const _KindBadge({required this.isConfirmation});

  @override
  Widget build(BuildContext context) {
    final color = isConfirmation
        ? const Color(0xFFD98C2B)
        : const Color(0xFF6A5ACD);
    final bg = isConfirmation
        ? const Color(0xFFFDF4E7)
        : const Color(0xFFECEAF9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isConfirmation ? 'تأكيد' : 'توقيع',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextStyle textStyle;
  final Color? iconColor;

  const _IconLabel({
    required this.icon,
    required this.text,
    required this.textStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor ?? const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: textStyle)),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _MetaChip({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF6B7280);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: c)),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(LucideIcons.circleCheck, size: 48, color: Color(0xFF2E9E6B)),
          SizedBox(height: 16),
          Text(
            "لا توجد مهام معلّقة",
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const _ErrorView({required this.onRetry, required this.message});

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
          const Text(
            "تعذّر تحميل المهام",
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text("إعادة المحاولة"),
          ),
        ],
      ),
    );
  }
}
