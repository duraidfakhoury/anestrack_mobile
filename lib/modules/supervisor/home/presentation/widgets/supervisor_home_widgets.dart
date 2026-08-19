import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/blocs/unread_count_bloc.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/routes/notifications_route.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/entities/current_user.dart';
import 'package:anestrack_mobile/modules/common/profile/presentation/blocs/current_user_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/hospitals_bloc/hospitals_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/entities/supervisor_dashboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Header: gradient banner with avatar, name, role badge, title, and the
/// notification bell — mirrors `student_home_screen.dart`'s `_header` but
/// with `AppColors.supervisorPrimary` (indigo) instead of the teal/cyan
/// student gradient.
class SupervisorHomeHeader extends StatelessWidget {
  const SupervisorHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 24, right: 20, left: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.supervisorPrimary, AppColors.indigo600],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: BlocBuilder<CurrentUserBloc, BaseState<CurrentUser>>(
              builder: (context, state) => _Identity(user: state.data),
            ),
          ),
          _NotificationBell(),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.user});

  final CurrentUser? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? '...';
    final title = user?.professionalTitle ?? user?.employeePosition;

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.user, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amber600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      LocaleKeys.login_supervisor.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (title != null && title.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
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
                          color: AppColors.supervisorPrimary,
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
}

/// "اختر المستشفى" label + a filled indigo dropdown pill ("جميع المستشفيات"
/// as the client-side "All Hospitals" sentinel, `value == null`).
class HospitalFilterDropdown extends StatelessWidget {
  const HospitalFilterDropdown({
    super.key,
    required this.selectedHospitalId,
    required this.onChanged,
  });

  final String? selectedHospitalId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.building2,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                LocaleKeys.supervisor_home_choose_hospital.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BlocBuilder<HospitalsBloc, HospitalsState>(
            builder: (context, state) {
              final hospitals = state.data ?? const <Hospital>[];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.supervisorPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedHospitalId,
                    isExpanded: true,
                    dropdownColor: AppColors.supervisorPrimary,
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          LocaleKeys.supervisor_home_all_hospitals.tr(),
                        ),
                      ),
                      ...hospitals.map(
                        (h) => DropdownMenuItem<String?>(
                          value: h.id,
                          child: Text(h.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: onChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The 2 top stat cards: approved procedures (out of the total) and
/// pending review.
class DashboardTopStats extends StatelessWidget {
  const DashboardTopStats({super.key, required this.stats});

  final SupervisorDashboardStats? stats;

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalProcedures ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _TopStatCard(
              value: '${stats?.approvedProcedures ?? 0}',
              label: LocaleKeys.supervisor_home_approved_procedures.tr(),
              subtitle: LocaleKeys.supervisor_home_out_of_total.tr(args: ['$total']),
              icon: LucideIcons.check,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TopStatCard(
              value: '${stats?.pendingReview ?? 0}',
              label: LocaleKeys.supervisor_home_pending_approvals.tr(),
              subtitle: LocaleKeys.supervisor_home_requires_immediate_review.tr(),
              icon: LucideIcons.circleAlert,
              color: AppColors.red600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStatCard extends StatelessWidget {
  const _TopStatCard({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Hand-rolled horizontal bar chart (no charting dependency) for
/// "توزيع الإجراءات حسب النوع" — one row per procedure type, bar length
/// proportional to that type's count relative to the highest count.
class ProceduresByTypeChart extends StatelessWidget {
  const ProceduresByTypeChart({super.key, required this.byProcedureType});

  final List<ProcedureTypeCount> byProcedureType;

  @override
  Widget build(BuildContext context) {
    if (byProcedureType.isEmpty) return const SizedBox.shrink();

    final maxCount = byProcedureType
        .map((d) => d.count)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  LucideIcons.trendingUp,
                  size: 16,
                  color: AppColors.supervisorPrimary,
                ),
                Text(
                  LocaleKeys.supervisor_home_procedures_by_type_title.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...byProcedureType.map(
              (d) => _ProcedureTypeRow(item: d, maxCount: maxCount),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcedureTypeRow extends StatelessWidget {
  const _ProcedureTypeRow({required this.item, required this.maxCount});

  final ProcedureTypeCount item;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount == 0 ? 0.0 : item.count / maxCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(height: 8, color: AppColors.gray100),
                    FractionallySizedBox(
                      widthFactor: ratio.clamp(0, 1),
                      child: Container(
                        height: 8,
                        color: AppColors.supervisorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '${item.count}',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The 3 "general statistics" cards: total procedures, rejected procedures,
/// active students.
class GeneralStatsSection extends StatelessWidget {
  const GeneralStatsSection({super.key, required this.stats});

  final SupervisorDashboardStats? stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.supervisor_home_general_statistics.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GeneralStatCard(
                  value: '${stats?.totalProcedures ?? 0}',
                  label: LocaleKeys.supervisor_home_total_procedures.tr(),
                  color: AppColors.blue600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GeneralStatCard(
                  value: '${stats?.rejectedProcedures ?? 0}',
                  label: LocaleKeys.supervisor_home_rejected_procedures.tr(),
                  color: AppColors.red600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GeneralStatCard(
                  value: '${stats?.totalStudents ?? 0}',
                  label: LocaleKeys.supervisor_home_active_students.tr(),
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GeneralStatCard extends StatelessWidget {
  const _GeneralStatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
