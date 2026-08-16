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
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/create_procedure_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  // Procedure-derived stat cards (belong to the main procedure flow).
  static const List<Map<String, dynamic>> _statsCards = [
    {
      'label': 'إجمالي الإجراءات المسجلة',
      'value': '47',
      'icon': LucideIcons.fileCheck,
      'gradient': [Color(0xFF14B8A6), Color(0xFF0D9488)],
    },
    {
      'label': 'حالة التقييم',
      'value': '38',
      'subtitle': 'ممتاز: 22 | جيد: 12 | مقبول: 4',
      'icon': LucideIcons.award,
      'gradient': [Color(0xFF3B82F6), Color(0xFF2563EB)],
    },
    {
      'label': 'نتائج الاختبارات',
      'value': '85%',
      'subtitle': 'متوسط الدرجات',
      'icon': LucideIcons.trendingUp,
      'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
    },
  ];

  static const int _currentYear = 3;
  static const int _loggedProcedures = 120;
  static const int _requiredProcedures = 200;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<CurrentUserBloc>()..add(FetchCurrentUserEvent()),
        ),
        BlocProvider(
          create: (_) => sl<AnnouncementsBloc>()..add(FetchAnnouncementsEvent()),
        ),
        BlocProvider(
          create: (_) => sl<UnreadCountBloc>()..add(FetchUnreadCountEvent()),
        ),
      ],
      child: const _StudentHomeView(),
    );
  }
}

class _StudentHomeView extends StatelessWidget {
  const _StudentHomeView();

  double get _progressPercentage =>
      StudentHomeScreen._loggedProcedures / StudentHomeScreen._requiredProcedures;

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            _progressCard(context),
            _announcementsSection(context),
          ],
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
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
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
          SizedBox(
            height: 135,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: StudentHomeScreen._statsCards.length,
              itemBuilder: (context, idx) =>
                  _statCard(StudentHomeScreen._statsCards[idx]),
            ),
          ),
        ],
      ),
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
                  style: const TextStyle(color: Color(0xFFA5F3FC), fontSize: 11),
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
                      constraints:
                          const BoxConstraints(minWidth: 14, minHeight: 14),
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تقدم السنة ${StudentHomeScreen._currentYear}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'انقر لعرض الخطة الدراسية الكاملة',
                        style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 13),
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
                  value: _progressPercentage,
                  minHeight: 10,
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(_progressPercentage * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'المسجل: ${StudentHomeScreen._loggedProcedures} / المطلوب: ${StudentHomeScreen._requiredProcedures}',
                    style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 12),
                  ),
                ],
              ),
            ],
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
              final items = (state.data ?? const <Announcement>[]).take(3).toList();
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'لا توجد إعلانات',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  ),
                );
              }
              return Column(
                children: items.map(_announcementTile).toList(),
              );
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
