import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/create_procedure_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  // Stat Cards Configuration Map
  final List<Map<String, dynamic>> _statsCards = [
    {
      'label': 'إجمالي الإجراءات المسجلة',
      'value': '47',
      'icon': LucideIcons.fileCheck,
      'gradient': const [
        Color(0xFF14B8A6),
        Color(0xFF0D9488),
      ], // teal-500 to teal-600
    },
    {
      'label': 'حالة التقييم',
      'value': '38',
      'subtitle': 'ممتاز: 22 | جيد: 12 | مقبول: 4',
      'icon': LucideIcons.award,
      'gradient': const [
        Color(0xFF3B82F6),
        Color(0xFF2563EB),
      ], // blue-500 to blue-600
    },
    {
      'label': 'نتائج الاختبارات',
      'value': '85%',
      'subtitle': 'متوسط الدرجات',
      'icon': LucideIcons.trendingUp,
      'gradient': const [
        Color(0xFF06B6D4),
        Color(0xFF0891B2),
      ], // cyan-500 to cyan-600
    },
  ];

  // Announcements Data Structure
  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'تحديث: بروتوكول جديد للتخدير النخاعي',
      'date': 'منذ ساعتين',
      'important': true,
    },
    {
      'title': 'اجتماع القسم يوم الأربعاء الساعة 2 ظهراً',
      'date': 'اليوم',
      'important': false,
    },
    {
      'title': 'محاضرة جديدة: إدارة الألم الحاد',
      'date': 'أمس',
      'important': false,
    },
  ];

  // Metrics Logic Variables
  final int _currentYear = 3;
  final int _loggedProcedures = 120;
  final int _requiredProcedures = 200;

  double get _progressPercentage => (_loggedProcedures / _requiredProcedures);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // gray-50
      floatingActionButton: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 16, left: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0D9488),
              Color(0xFF0891B2),
            ], // teal-600 to cyan-600
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0891B2).withOpacity(0.3),
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
      // Matches left-6 placement
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Core Header Frame
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 24,
                right: 20,
                left: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D9488),
                    Color(0xFF0891B2),
                  ], // teal-600 to cyan-700
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
                  // Identity Panel Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.user,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "د. أحمد العمري",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "مستشفى الملك فيصل التخصصي",
                                style: TextStyle(
                                  color: Color(0xFFCFFAFE),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "مقيم سنة ثالثة - تخدير",
                                style: TextStyle(
                                  color: Color(0xFFA5F3FC),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Notification Alert Node
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, '/notifications'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                LucideIcons.bell,
                                color: Colors.white,
                                size: 20,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF0D9488),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Badges Horizontal Pipeline
                  SizedBox(
                    height: 135,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statsCards.length,
                      itemBuilder: (context, idx) {
                        final card = _statsCards[idx];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: card['gradient'],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  card['icon'],
                                  color: Colors.white,
                                  size: 18,
                                ),
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
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Performance Tracking Matrix (Year Progress Widget)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/curriculum'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4F46E5),
                        Color(0xFF4338CA),
                      ], // indigo-600 to indigo-700
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.25),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "تقدم السنة $_currentYear",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "انقر لعرض الخطة الدراسية الكاملة",
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
                      // Linear Gauge Indicator
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _progressPercentage,
                          minHeight: 10,
                          backgroundColor: Colors.black.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFBBF24),
                          ), // amber-400
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${(_progressPercentage * 100).round()}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "المسجل: $_loggedProcedures / المطلوب: $_requiredProcedures",
                            style: const TextStyle(
                              color: Color(0xFFE0E7FF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Announcement Cluster
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "آخر الإعلانات",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/announcements'),
                        child: const Text(
                          "عرض الكل",
                          style: TextStyle(
                            color: Color(0xFF0D9488),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Column(
                    children: _announcements.map((announcement) {
                      final bool isImportant =
                          announcement['important'] ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isImportant
                              ? const Border(
                                  right: BorderSide(
                                    color: Colors.red,
                                    width: 4,
                                  ),
                                )
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
                                    announcement['title'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isImportant
                                          ? const Color(0xFFB91C1C)
                                          : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    announcement['date'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isImportant)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "مهم",
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
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 100,
                  ), // Spacing safe-harbor layer for FAB overlapping
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
