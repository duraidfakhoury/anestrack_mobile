import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.studentPrimary,
        foregroundColor: AppColors.white,
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowRight),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('الإشعارات'),
          _card([
            _SwitchRow(
              icon: LucideIcons.bell,
              label: 'الإشعارات الفورية',
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
            ),
          ]),
          const SizedBox(height: 20),
          _sectionTitle('حول التطبيق'),
          _card([
            const _InfoRow(
              icon: LucideIcons.info,
              label: 'الإصدار',
              value: 'AnesTrack v1.0.0',
            ),
            const Divider(height: 1, color: AppColors.gray100),
            const _InfoRow(
              icon: LucideIcons.languages,
              label: 'اللغة',
              value: 'العربية',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(right: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.slate700,
      ),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.gray100),
    ),
    child: Column(children: children),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.slate600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.studentPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.slate600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.slate900),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}
