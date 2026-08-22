import 'dart:async';

import 'package:anestrack_mobile/core/services/connectivity/connectivity_service.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/core/utils/relative_time.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';
import 'package:anestrack_mobile/modules/common/announcements/presentation/blocs/announcements_bloc.dart';
import 'package:anestrack_mobile/modules/common/announcements/presentation/routes/announcements_route.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/blocs/unread_count_bloc.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/routes/notifications_route.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/entities/current_user.dart';
import 'package:anestrack_mobile/modules/common/profile/presentation/blocs/current_user_bloc.dart';
import 'package:anestrack_mobile/modules/student/home/domain/entities/student_dashboard.dart';
import 'package:anestrack_mobile/modules/student/home/presentation/blocs/student_dashboard_bloc/student_dashboard_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/create_procedure_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  // Presentation metadata for the procedure-derived stat cards; the values
  // themselves come from StudentDashboardBloc (getStudentDashboard).
  static const List<Map<String, dynamic>> _statsCardsMeta = [
    {
      'label': 'إجمالي الإجراءات المسجلة',
      'icon': LucideIcons.fileCheck,
      'gradient': [Color(0xFF14B8A6), Color(0xFF0D9488)],
    },
    {
      'label': 'حالة التقييم',
      'icon': LucideIcons.award,
      'gradient': [Color(0xFF3B82F6), Color(0xFF2563EB)],
    },
    {
      'label': 'متوسط درجة التقييم',
      'icon': LucideIcons.trendingUp,
      'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
    },
  ];

  static const int _fallbackYear = 2;
  // The curriculum's required-procedures quota isn't part of
  // getStudentDashboard yet; kept static until that's exposed by the backend.
  static const int _requiredProcedures = 300;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<CurrentUserBloc>()..add(FetchCurrentUserEvent()),
        ),
        BlocProvider(
          create: (_) =>
              sl<AnnouncementsBloc>()..add(FetchAnnouncementsEvent()),
        ),
        BlocProvider(
          create: (_) =>
              sl<StudentDashboardBloc>()..add(FetchStudentDashboardEvent()),
        ),
        // UnreadCountBloc is a singleton owned by the service locator (see
        // service_locator.dart), so it must be provided via `.value` rather
        // than `create` — `create` would make flutter_bloc close() it when
        // this screen is disposed (e.g. on logout), permanently breaking the
        // singleton for the next login.
        BlocProvider.value(
          value: sl<UnreadCountBloc>()..add(FetchUnreadCountEvent()),
        ),
        // Same singleton-bloc rule as UnreadCountBloc above.
        BlocProvider.value(
          value: sl<PendingProceduresBloc>()
            ..add(const FetchPendingProceduresEvent()),
        ),
      ],
      child: const _StudentHomeView(),
    );
  }
}

class _StudentHomeView extends StatelessWidget {
  const _StudentHomeView();

  Future<void> _onRefresh(BuildContext context) async {
    context.read<CurrentUserBloc>().add(FetchCurrentUserEvent());
    context.read<AnnouncementsBloc>().add(RefreshAnnouncementsEvent());
    context.read<StudentDashboardBloc>().add(FetchStudentDashboardEvent());
    context.read<UnreadCountBloc>().add(FetchUnreadCountEvent());
    context.read<PendingProceduresBloc>().add(
      const RefreshPendingProceduresEvent(),
    );
    await Future.wait([
      context.read<CurrentUserBloc>().stream.firstWhere((s) => !s.isLoading),
      context.read<AnnouncementsBloc>().stream.firstWhere((s) => !s.isLoading),
      context.read<StudentDashboardBloc>().stream.firstWhere(
        (s) => !s.isLoading,
      ),
      context.read<UnreadCountBloc>().stream.firstWhere((s) => !s.isLoading),
      context.read<PendingProceduresBloc>().stream.firstWhere(
        (s) => !s.isLoading,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 16, left: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0891B2).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => context.push(CreateProcedureRoute.name),
            child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const _OfflineIndicator(),
              _pendingBanner(context),
              _progressCard(context),
              _announcementsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 24, right: 20, left: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BlocBuilder<CurrentUserBloc, BaseState<CurrentUser>>(
                  builder: (context, state) => _identity(state.data),
                ),
              ),
              _notificationBell(context),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
            builder: (context, state) {
              final cards = _statsCardValues(state.data);
              return SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length,
                  itemBuilder: (context, idx) => _statCard(cards[idx]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Merges the static card metadata with live values from
  /// `getStudentDashboard`; `stats == null` while loading or on error.
  List<Map<String, dynamic>> _statsCardValues(StudentDashboardStats? stats) {
    final meta = StudentHomeScreen._statsCardsMeta;
    if (stats == null) {
      return [
        for (final card in meta) {...card, 'value': '...'},
      ];
    }

    final eval = stats.evaluation;
    return [
      {...meta[0], 'value': '${stats.totalProcedures}'},
      {
        ...meta[1],
        'value': '${eval.totalEvaluated}',
        'subtitle':
            'ممتاز: ${eval.excellentCount} | جيد: ${eval.goodCount} | مقبول: ${eval.acceptableCount}',
      },
      {
        ...meta[2],
        'value': eval.averageScore.toStringAsFixed(1),
        'subtitle': _performanceLabel(eval.performance),
      },
    ];
  }

  String _performanceLabel(String performance) {
    switch (performance) {
      case 'Excellent':
        return 'ممتاز';
      case 'Good':
        return 'جيد';
      case 'Acceptable':
        return 'مقبول';
      case 'Poor':
        return 'ضعيف';
      case 'Not Evaluated':
        return 'لم يتم التقييم بعد';
      default:
        return performance;
    }
  }

  Widget _pendingBanner(BuildContext context) {
    return BlocBuilder<PendingProceduresBloc, PendingProceduresState>(
      builder: (context, state) {
        final count = state.data?.length ?? 0;
        if (count == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.cloudUpload,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$count إجراء بانتظار المزامنة',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _identity(CurrentUser? user) {
    final name = user?.fullName ?? '...';
    final year = user?.yearCode;
    final sub = user == null
        ? ''
        : (user.isStudent
              ? (year != null ? 'طالب - السنة $year' : 'طالب')
              : (user.employeePosition ?? 'مشرف'));
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.user, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  style: const TextStyle(
                    color: Color(0xFFA5F3FC),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _notificationBell(BuildContext context) {
    return InkWell(
      onTap: () => context.push(NotificationsRoute.name),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: BlocBuilder<UnreadCountBloc, BaseState<int>>(
          builder: (context, state) {
            final count = state.data ?? 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                const Icon(LucideIcons.bell, color: Colors.white, size: 20),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF0D9488),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(Map<String, dynamic> card) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: card['gradient']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(card['icon'], color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            card['value'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            card['label'],
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (card['subtitle'] != null) ...[
            const SizedBox(height: 2),
            Text(
              card['subtitle'],
              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _progressCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () => context.push('/curriculum'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
            builder: (context, dashboardState) {
              final logged = dashboardState.data?.totalProcedures ?? 0;
              final percentage =
                  (logged / StudentHomeScreen._requiredProcedures).clamp(
                    0.0,
                    1.0,
                  );
              return BlocBuilder<CurrentUserBloc, BaseState<CurrentUser>>(
                builder: (context, userState) {
                  final year =
                      userState.data?.yearCode ??
                      StudentHomeScreen._fallbackYear;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تقدم السنة $year',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'انقر لعرض الخطة الدراسية الكاملة',
                                style: TextStyle(
                                  color: Color(0xFFE0E7FF),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            LucideIcons.trendingUp,
                            color: Color(0xFFC7D2FE),
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 10,
                          backgroundColor: Colors.black.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFBBF24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(percentage * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'المسجل: $logged / المطلوب: ${StudentHomeScreen._requiredProcedures}',
                            style: const TextStyle(
                              color: Color(0xFFE0E7FF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _announcementsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'آخر الإعلانات',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: () => context.push(AnnouncementsRoute.name),
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(color: Color(0xFF0D9488), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          BlocBuilder<AnnouncementsBloc, BaseState<List<Announcement>>>(
            builder: (context, state) {
              if (state.isLoading || state.isInit) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                );
              }
              final items = (state.data ?? const <Announcement>[])
                  .take(3)
                  .toList();
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'لا توجد إعلانات',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  ),
                );
              }
              return Column(children: items.map(_announcementTile).toList());
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _announcementTile(Announcement a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: a.isImportant
            ? const Border(right: BorderSide(color: Colors.red, width: 4))
            : Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: a.isImportant
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF1F2937),
                  ),
                ),
                if (a.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    formatRelative(a.createdAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (a.isImportant)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'مهم',
                style: TextStyle(
                  color: Color(0xFFB91C1C),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Live device-connectivity banner — distinct from `_pendingBanner`, which
/// shows the count of items already queued. This shows the real-time
/// online/offline state driving that queue.
class _OfflineIndicator extends StatefulWidget {
  const _OfflineIndicator();

  @override
  State<_OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<_OfflineIndicator> {
  final ConnectivityService _connectivityService = sl<ConnectivityService>();
  bool _isOffline = false;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _connectivityService.isOnline().then((online) {
      if (mounted) setState(() => _isOffline = !online);
    });
    _subscription = _connectivityService.onConnectivityChanged.listen((online) {
      if (mounted) setState(() => _isOffline = !online);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.wifiOff, size: 16, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'لا يوجد اتصال بالإنترنت — سيتم حفظ أي إجراء جديد محلياً',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF991B1B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
