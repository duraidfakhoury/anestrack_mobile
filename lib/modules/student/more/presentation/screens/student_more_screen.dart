import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/core_components/show_snack_bar.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/auth/presentation/blocs/logout_bloc/logout_bloc.dart';
import 'package:anestrack_mobile/modules/auth/presentation/routes/login_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StudentMoreScreen extends StatelessWidget {
  const StudentMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LogoutBloc>(),
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
          final menuItems = _menuItems(context);
          final isLoading = state.isLoading;

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _MoreHeaderDelegate(
                  title: 'nav.more'.tr(context: context),
                  subtitle: 'more.settingsandmoreoptions'.tr(context: context),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'د. أحمد العمري',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'مقيم سنة ثالثة - تخدير',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'مستشفى الملك فيصل التخصصي',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.teal500,
                                    AppColors.cyan600,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.user,
                                color: AppColors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: menuItems
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MoreMenuTile(item: item),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<LogoutBloc>()
                                  .add(const LogoutRequestedEvent()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red100,
                            foregroundColor: AppColors.red600,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.red200),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      LucideIcons.logOut,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'logout'.tr(context: context),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'AnesTrack v1.0.0',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.slate500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'app.allrightspreserved'.tr(context: context),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_MoreMenuItem> _menuItems(BuildContext context) => [
    _MoreMenuItem(
      icon: LucideIcons.user,
      label: 'more.profile'.tr(context: context),
      description: 'more.viewandedityourinfo'.tr(context: context),
      colors: const [AppColors.blue100, AppColors.blue600],
      onTap: () => context.go('/profile'),
    ),
    _MoreMenuItem(
      icon: LucideIcons.bookOpen,
      label: 'more.educationalplan'.tr(context: context),
      description: 'more.requirmentsandskillsrequired'.tr(context: context),
      colors: const [AppColors.studentPrimaryLight, AppColors.studentPrimary],
      onTap: () => context.go('/curriculum'),
    ),
    _MoreMenuItem(
      icon: LucideIcons.alertCircle,
      label: 'more.complaint'.tr(context: context),
      description: 'more.fileacomplaint'.tr(context: context),
      colors: const [AppColors.red100, AppColors.red600],
      onTap: () => _showComplaintSheet(context),
    ),
    _MoreMenuItem(
      icon: LucideIcons.settings,
      label: 'more.settings'.tr(context: context),
      description: 'more.configureyourappsettings'.tr(context: context),
      colors: const [AppColors.gray100, AppColors.slate600Dark],
      onTap: () => context.go('/settings'),
    ),
    _MoreMenuItem(
      icon: LucideIcons.helpCircle,
      label: 'more.help'.tr(context: context),
      description: 'more.commonlyaskedquestionsandtechnicalsupport'.tr(
        context: context,
      ),
      colors: const [AppColors.purple100, AppColors.purple600],
      onTap: () => context.go('/support'),
    ),
  ];

  Future<void> _showComplaintSheet(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool agreed = false;
    bool showAgreementError = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.gray300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.red100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.lock,
                                color: AppColors.red600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تقديم شكوى سرية',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'سيتم إرسالها مباشرة للإدارة',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.amber50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.amber200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(
                                LucideIcons.alertCircle,
                                color: AppColors.amber600,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'معلومات سرية ومحمية',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.amber800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'هذه الشكوى سرية بالكامل وسيتم إرسالها مباشرة إلى مدير البرنامج. لن يتم مشاركة هويتك إلا إذا كان ذلك ضرورياً.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.amber700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'موضوع الشكوى *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: null,
                          items: const [
                            DropdownMenuItem(
                              value: 'supervisor',
                              child: Text('تتعلق بالمشرف'),
                            ),
                            DropdownMenuItem(
                              value: 'training',
                              child: Text('تتعلق بالتدريب'),
                            ),
                            DropdownMenuItem(
                              value: 'environment',
                              child: Text('بيئة العمل'),
                            ),
                            DropdownMenuItem(
                              value: 'harassment',
                              child: Text('تحرش أو سوء معاملة'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('أخرى'),
                            ),
                          ],
                          onChanged: (_) {},
                          validator: (value) =>
                              value == null ? 'اختر نوع الشكوى' : null,
                          decoration: _inputDecoration(
                            hintText: 'اختر نوع الشكوى',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'تفاصيل الشكوى *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller,
                          maxLines: 6,
                          decoration: _inputDecoration(
                            hintText: 'اكتب تفاصيل الشكوى هنا...',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'اكتب تفاصيل الشكوى'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: agreed,
                              onChanged: (value) => setModalState(() {
                                agreed = value ?? false;
                                if (agreed) {
                                  showAgreementError = false;
                                }
                              }),
                            ),
                            const Expanded(
                              child: Text(
                                'أوافق على إرسال هذه الشكوى وأفهم أنها سرية ومحمية',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.slate600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (showAgreementError)
                          const Padding(
                            padding: EdgeInsets.only(left: 12, bottom: 8),
                            child: Text(
                              'يرجى الموافقة على الإقرار',
                              style: TextStyle(
                                color: AppColors.red600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final isValid =
                                  formKey.currentState?.validate() ?? false;
                              if (!agreed) {
                                setModalState(() {
                                  showAgreementError = true;
                                });
                                return;
                              }
                              if (!isValid) return;

                              Navigator.of(sheetContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إرسال الشكوى بنجاح'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red600,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(LucideIcons.send, size: 18),
                            label: const Text(
                              'إرسال الشكوى',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.slate700,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(color: AppColors.gray200),
                              backgroundColor: AppColors.gray100,
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }
}

class _MoreMenuTile extends StatelessWidget {
  const _MoreMenuTile({required this.item});

  final _MoreMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.colors.first,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.colors.last),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.arrowRight,
                size: 18,
                color: AppColors.slate500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreHeaderDelegate extends SliverPersistentHeaderDelegate {
  _MoreHeaderDelegate({required this.title, required this.subtitle});

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
            colors: [AppColors.studentPrimary, AppColors.studentPrimaryDark],
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
              style: const TextStyle(
                color: AppColors.studentPrimaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MoreHeaderDelegate oldDelegate) {
    return title != oldDelegate.title || subtitle != oldDelegate.subtitle;
  }
}

class _MoreMenuItem {
  const _MoreMenuItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final List<Color> colors;
  final VoidCallback onTap;
}

InputDecoration _inputDecoration({required String hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.slate500, fontSize: 12),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.gray200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.gray200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.studentPrimary, width: 1.5),
    ),
  );
}
