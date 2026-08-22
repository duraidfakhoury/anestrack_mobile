import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/entities/current_user.dart';
import 'package:anestrack_mobile/modules/common/profile/presentation/blocs/current_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CurrentUserBloc>()..add(FetchCurrentUserEvent()),
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        body: BlocBuilder<CurrentUserBloc, BaseState<CurrentUser>>(
          builder: (context, state) {
            if (state.isLoading || state.isInit) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.isError) {
              return _ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<CurrentUserBloc>().add(
                  FetchCurrentUserEvent(),
                ),
              );
            }
            final user = state.data!;
            return RefreshIndicator(
              onRefresh: () {
                context.read<CurrentUserBloc>().add(FetchCurrentUserEvent());
                return context.read<CurrentUserBloc>().stream.firstWhere(
                  (s) => !s.isLoading,
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _Header(user: user)),
                  SliverToBoxAdapter(child: _InfoSection(user: user)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final CurrentUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 56, bottom: 28, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.studentPrimary, AppColors.cyan600],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.arrowRight,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.user,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _roleLine(user),
            style: const TextStyle(
              color: AppColors.studentPrimaryLight,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _roleLine(CurrentUser user) {
    if (user.isStudent) {
      final year = user.yearCode;
      return year != null ? 'طالب - السنة $year' : 'طالب';
    }
    return user.employeePosition?.isNotEmpty == true
        ? user.employeePosition!
        : 'مشرف';
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.user});
  final CurrentUser user;

  @override
  Widget build(BuildContext context) {
    final rows = <({IconData icon, String label, String value})>[
      (icon: LucideIcons.atSign, label: 'اسم المستخدم', value: user.username),
      if (user.nationalId.isNotEmpty)
        (
          icon: LucideIcons.creditCard,
          label: 'الرقم الوطني',
          value: user.nationalId,
        ),
      if (user.mobileNumber.isNotEmpty)
        (
          icon: LucideIcons.phone,
          label: 'رقم الجوال',
          value: user.mobileNumber,
        ),
      if (user.employeeEmail?.isNotEmpty == true)
        (
          icon: LucideIcons.mail,
          label: 'البريد الإلكتروني',
          value: user.employeeEmail!,
        ),
      if (user.employeeId?.isNotEmpty == true)
        (
          icon: LucideIcons.badgeCheck,
          label: 'الرقم الوظيفي',
          value: user.employeeId!,
        ),
      (
        icon: LucideIcons.userCog,
        label: 'نوع الحساب',
        value: user.isStudent ? 'طالب' : (user.isSuperAdmin ? 'مدير' : 'مشرف'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray100),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  color: AppColors.gray100,
                  indent: 16,
                  endIndent: 16,
                ),
              _InfoRow(
                icon: rows[i].icon,
                label: rows[i].label,
                value: rows[i].value,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.slate600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.circleAlert,
              size: 40,
              color: AppColors.red600,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
