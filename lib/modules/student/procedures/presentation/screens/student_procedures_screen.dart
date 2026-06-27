import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_state.dart';

class StudentProceduresScreen extends StatefulWidget {
  const StudentProceduresScreen({super.key});

  @override
  State<StudentProceduresScreen> createState() =>
      _StudentProceduresScreenState();
}

class _StudentProceduresScreenState extends State<StudentProceduresScreen> {
  late ProceduresBloc _proceduresBloc;
  String _filterStatus = 'all';

  // Map configuration filtering labels
  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'pending', 'label': 'قيد المراجعة'},
    {'id': 'evaluated', 'label': 'تم التقييم'},
    {'id': 'approved', 'label': 'معتمد'},
    {'id': 'rejected', 'label': 'مرفوض'},
  ];

  // Translation helpers for statuses
  final Map<String, Map<String, dynamic>> _statusConfig = {
    'pending': {
      'label': 'قيد المراجعة',
      'icon': LucideIcons.clock,
      'bgColor': const Color(0xFFFEF3C7), // bg-amber-100
      'textColor': const Color(0xFFB45309), // text-amber-700
      'borderColor': const Color(0xFFFDE68A), // border-amber-200
    },
    'approved': {
      'label': 'معتمد',
      'icon': LucideIcons.checkCircle,
      'bgColor': const Color(0xFFD1FAE5), // bg-green-100
      'textColor': const Color(0xFF047857), // text-green-700
      'borderColor': const Color(0xFFA7F3D0), // border-green-200
    },
    'rejected': {
      'label': 'مرفوض',
      'icon': LucideIcons.xCircle,
      'bgColor': const Color(0xFFFEE2E2), // bg-red-100
      'textColor': const Color(0xFFB91C1C), // text-red-700
      'borderColor': const Color(0xFFFCA5A5), // border-red-200
    },
    'evaluated': {
      'label': 'تم التقييم',
      'icon': LucideIcons.award,
      'bgColor': const Color(0xFFDBEAFE), // bg-blue-100
      'textColor': const Color(0xFF1D4ED8), // text-blue-700
      'borderColor': const Color(0xFFBFDBFE), // border-blue-200
    },
  };

  final Map<String, String> _ratingLabels = {
    'excellent': 'ممتاز',
    'good': 'جيد',
    'acceptable': 'مقبول',
  };

  @override
  void initState() {
    super.initState();
    _proceduresBloc = sl<ProceduresBloc>();
    _proceduresBloc.add(
      FetchProceduresEvent(
        ListProceduresParameters(),
      ),
    );
  }

  @override
  void dispose() {
    _proceduresBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocBuilder<ProceduresBloc, ProceduresState>(
        bloc: _proceduresBloc,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Styled Header Area
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
                    ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "إجراءاتي",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${state.data?.length ?? 0} إجراء مسجل",
                      style: const TextStyle(
                        color: Color(0xFFCFFAFE),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Filtering Chips Section
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(
                          LucideIcons.filter,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "تصفية حسب الحالة",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, idx) {
                          final item = _filters[idx];
                          final bool isSelected = _filterStatus == item['id'];

                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ChoiceChip(
                              label: Text(item['label']!),
                              selected: isSelected,
                              selectedColor: const Color(0xFF0D9488),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              onSelected: (_) {
                                setState(() => _filterStatus = item['id']!);
                                _proceduresBloc.add(
                                  FilterProceduresByStatusEvent(item['id']!),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Content based on state
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(ProceduresState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              "حدث خطأ في تحميل الإجراءات",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _proceduresBloc.add(
                  FetchProceduresEvent(
                    ListProceduresParameters(),
                  ),
                );
              },
              child: const Text("إعادة المحاولة"),
            ),
          ],
        ),
      );
    }

    final procedures = state.data ?? [];
    if (procedures.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: procedures.length,
      itemBuilder: (context, idx) {
        final proc = procedures[idx];
        final config = _statusConfig[proc.status]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
            border: Border(
              right: BorderSide(
                color: config['borderColor'],
                width: 4,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proc.procedure,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proc.hospital,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "المريض: ${proc.patientId}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: config['bgColor'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          config['icon'],
                          color: config['textColor'],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          config['label'],
                          style: TextStyle(
                            color: config['textColor'],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF3F4F6)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          proc.date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    if (proc.status == 'evaluated' && proc.rating != null)
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.award,
                            size: 16,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _ratingLabels[proc.rating]!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Placeholder Widget for Empty State Responses
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.clock,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "لا توجد إجراءات بهذا التصنيف",
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
