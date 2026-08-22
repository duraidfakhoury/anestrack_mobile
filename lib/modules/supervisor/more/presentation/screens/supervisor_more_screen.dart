import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/core_components/show_snack_bar.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/auth/presentation/blocs/logout_bloc/logout_bloc.dart';
import 'package:anestrack_mobile/modules/auth/presentation/routes/login_route.dart';
import 'package:anestrack_mobile/modules/common/announcements/presentation/routes/announcements_route.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/entities/current_user.dart';
import 'package:anestrack_mobile/modules/common/profile/presentation/blocs/current_user_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupervisorMoreScreen extends StatefulWidget {
  const SupervisorMoreScreen({super.key});

  @override
  State<SupervisorMoreScreen> createState() => _SupervisorMoreScreenState();
}

class _SupervisorMoreScreenState extends State<SupervisorMoreScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LogoutBloc>()),
        BlocProvider(
          create: (_) => sl<CurrentUserBloc>()..add(FetchCurrentUserEvent()),
        ),
      ],
      child: BlocConsumer<LogoutBloc, BaseState<bool>>(
        listener: (context, state) {
          if (state.isError) {
            showSnackBar(context, failure: state.failure);
          }
          if (state.isSuccess) {
            context.go(LoginRoute.name);
          }
        },
        builder: (context, state) {
          final isLoading = state.isLoading;

          return Container(
            color: AppColors.slate50,
            child: RefreshIndicator(
              onRefresh: () {
                context.read<CurrentUserBloc>().add(FetchCurrentUserEvent());
                return context.read<CurrentUserBloc>().stream.firstWhere(
                  (s) => !s.isLoading,
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SupervisorHeaderDelegate(
                      title: 'nav.more'.tr(context: context),
                      subtitle: 'supervisor_more.subtitle'.tr(context: context),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildToggleCard(
                                icon: LucideIcons.mail,
                                iconColor: AppColors.blue600,
                                iconBg: AppColors.blue100,
                                title: 'supervisor_more.email_notifications'.tr(
                                  context: context,
                                ),
                                subtitle:
                                    'supervisor_more.email_notifications_subtitle'
                                        .tr(context: context),
                                value: _emailNotifications,
                                onChanged: (val) {
                                  setState(() => _emailNotifications = val);
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildToggleCard(
                                icon: LucideIcons.bell,
                                iconColor: AppColors.purple600,
                                iconBg: AppColors.purple100,
                                title: 'supervisor_more.push_notifications'.tr(
                                  context: context,
                                ),
                                subtitle:
                                    'supervisor_more.push_notifications_subtitle'
                                        .tr(context: context),
                                value: _pushNotifications,
                                onChanged: (val) {
                                  setState(() => _pushNotifications = val);
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildNavigationCard(
                                icon: LucideIcons.megaphone,
                                iconColor: AppColors.blue600,
                                iconBg: AppColors.blue100,
                                title: 'supervisor_more.announcements'.tr(
                                  context: context,
                                ),
                                subtitle:
                                    'supervisor_more.announcements_subtitle'.tr(
                                      context: context,
                                    ),
                                onTap: () =>
                                    context.push(AnnouncementsRoute.name),
                              ),
                              const SizedBox(height: 12),
                              _buildNavigationCard(
                                icon: LucideIcons.shield,
                                iconColor: AppColors.slate600,
                                iconBg: AppColors.gray100,
                                title: 'supervisor_more.privacy_security'.tr(
                                  context: context,
                                ),
                                subtitle:
                                    'supervisor_more.privacy_security_subtitle'
                                        .tr(context: context),
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'supervisor_more.account_info'.tr(
                                  context: context,
                                ),
                                style: const TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child:
                                    BlocBuilder<
                                      CurrentUserBloc,
                                      BaseState<CurrentUser>
                                    >(
                                      builder: (context, userState) {
                                        final user = userState.data;
                                        const dash = '—';
                                        return Column(
                                          children: [
                                            _buildAccountRow(
                                              'supervisor_more.name_label'.tr(
                                                context: context,
                                              ),
                                              user?.fullName ?? dash,
                                            ),
                                            const Divider(
                                              height: 24,
                                              color: AppColors.slate100,
                                            ),
                                            _buildAccountRow(
                                              'supervisor_more.email_label'.tr(
                                                context: context,
                                              ),
                                              (user
                                                          ?.employeeEmail
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? user!.employeeEmail!
                                                  : dash,
                                            ),
                                            const Divider(
                                              height: 24,
                                              color: AppColors.slate100,
                                            ),
                                            _buildAccountRow(
                                              'supervisor_more.role_label'.tr(
                                                context: context,
                                              ),
                                              user == null
                                                  ? dash
                                                  : (user
                                                                .employeePosition
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? user.employeePosition!
                                                        : (user.isSuperAdmin
                                                              ? 'مدير'
                                                              : 'مشرف')),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.read<LogoutBloc>().add(
                                      const LogoutRequestedEvent(),
                                    ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.red600,
                                backgroundColor: AppColors.red100,
                                side: const BorderSide(
                                  color: AppColors.red200,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.red600,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          LucideIcons.logOut,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'logout'.tr(context: context),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'supervisor_more.version'.tr(context: context),
                            style: const TextStyle(
                              color: AppColors.slate400,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.slate800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.supervisorPrimary,
            activeTrackColor: AppColors.supervisorPrimary.withValues(
              alpha: 0.3,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.slate800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.arrowRight,
              color: AppColors.slate400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountRow(String metric, String info) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric,
            style: const TextStyle(color: AppColors.slate400, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            info,
            style: const TextStyle(
              color: AppColors.slate800,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupervisorHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SupervisorHeaderDelegate({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  double get minExtent => 96;

  @override
  double get maxExtent => 120;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: 16,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.indigo800, AppColors.indigo900],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.indigo200, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SupervisorHeaderDelegate oldDelegate) {
    return title != oldDelegate.title || subtitle != oldDelegate.subtitle;
  }
}
