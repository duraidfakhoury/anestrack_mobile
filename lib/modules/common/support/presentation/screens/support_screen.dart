import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const List<({String q, String a})> _faqs = [
    (
      q: 'كيف أسجّل إجراءً جديداً؟',
      a: 'من الشاشة الرئيسية اضغط على زر الإضافة (+) ثم اختر نوع الإجراء والمستشفى وأكمل البيانات المطلوبة.',
    ),
    (
      q: 'ما هو التوقيع المشترك (Co-Sign)؟',
      a: 'هو تأكيد المشرف على قيامك بالإجراء، إما مباشرةً عبر رمز التوقيع أو لاحقاً بتأكيد المشرف المسؤول.',
    ),
    (
      q: 'كيف أتابع تقدّمي في الخطة الدراسية؟',
      a: 'من الشاشة الرئيسية اضغط على بطاقة "تقدم السنة" لعرض الخطة الدراسية والمتطلبات.',
    ),
    (
      q: 'كيف أقدّم شكوى؟',
      a: 'من قائمة "المزيد" اختر "تقديم شكوى"، واملأ النموذج. الشكوى سرية وتصل مباشرة إلى الإدارة.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.studentPrimary,
        foregroundColor: AppColors.white,
        title: const Text('المساعدة والدعم'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowRight),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'الأسئلة الشائعة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 12),
          ..._faqs.map(
            (f) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gray100),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: const Icon(
                    LucideIcons.circleHelp,
                    color: AppColors.studentPrimary,
                    size: 20,
                  ),
                  title: Text(
                    f.q,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        f.a,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.studentPrimary, AppColors.cyan600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.mail, color: AppColors.white, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الدعم الفني',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'support@anestrack.com',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                    ],
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
