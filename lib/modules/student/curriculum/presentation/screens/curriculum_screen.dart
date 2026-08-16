import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Educational plan / curriculum overview. Static reference content — the
/// program requirements per residency year.
class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});

  static const List<({int year, String title, int required, String focus})>
      _years = [
    (year: 1, title: 'السنة الأولى', required: 100, focus: 'أساسيات التخدير والتقييم قبل العملية'),
    (year: 2, title: 'السنة الثانية', required: 150, focus: 'التخدير الموضعي وإدارة مجرى الهواء'),
    (year: 3, title: 'السنة الثالثة', required: 200, focus: 'الحالات المعقدة والعناية المركزة'),
    (year: 4, title: 'السنة الرابعة', required: 250, focus: 'التخصص الدقيق والإشراف'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.indigo600,
        foregroundColor: AppColors.white,
        title: const Text('الخطة الدراسية'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowRight),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'متطلبات برنامج التخدير',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'الحد الأدنى من الإجراءات المطلوبة لكل سنة تدريبية',
            style: TextStyle(fontSize: 12, color: AppColors.slate500),
          ),
          const SizedBox(height: 16),
          ..._years.map(
            (y) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gray100),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.indigo200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${y.year}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.indigo800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          y.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          y.focus,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        '${y.required}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.indigo600,
                        ),
                      ),
                      const Text(
                        'إجراء',
                        style: TextStyle(fontSize: 10, color: AppColors.slate500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
