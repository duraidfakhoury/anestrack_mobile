import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/utils/procedure_display.dart';

class StudentProceduresScreen extends StatefulWidget {
  const StudentProceduresScreen({super.key});

  @override
  State<StudentProceduresScreen> createState() =>
      _StudentProceduresScreenState();
}

class _StudentProceduresScreenState extends State<StudentProceduresScreen> {
  late ProceduresBloc _proceduresBloc;
  String _filterStatus = 'all';

  final List<Map<String, String>> _filters = const [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'Pending', 'label': 'قيد المراجعة'},
    {'id': 'Approved', 'label': 'معتمد'},
    {'id': 'Rejected', 'label': 'مرفوض'},
  ];

  @override
  void initState() {
    super.initState();
    _proceduresBloc = sl<ProceduresBloc>();
    _proceduresBloc.add(FetchProceduresEvent(const ListProceduresParameters()));
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
              _buildHeader(state.data?.length ?? 0),
              _buildFilters(),
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int count) {
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
            "$count إجراء مسجل",
            style: const TextStyle(color: Color(0xFFCFFAFE), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.filter, size: 14, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Text(
                "تصفية حسب الحالة",
                style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
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
                final isSelected = _filterStatus == item['id'];
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
    );
  }

  Widget _buildContent(ProceduresState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              "حدث خطأ في تحميل الإجراءات",
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _proceduresBloc.add(
                FetchProceduresEvent(const ListProceduresParameters()),
              ),
              child: const Text("إعادة المحاولة"),
            ),
          ],
        ),
      );
    }

    final procedures = state.data ?? [];
    if (procedures.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: procedures.length,
      itemBuilder: (context, idx) => _ProcedureCard(procedure: procedures[idx]),
    );
  }

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

class _ProcedureCard extends StatelessWidget {
  final Procedure procedure;

  const _ProcedureCard({required this.procedure});

  String get _date => (procedure.procedureDate ?? procedure.createdAt ?? '')
      .split('T')
      .first;

  @override
  Widget build(BuildContext context) {
    final assurance = procedure.assuranceLevel;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
        border: Border(
          right: BorderSide(
            color: ProcedureDisplay.assuranceColor(assurance),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      procedure.procedureTypeName ?? 'إجراء',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      procedure.hospitalName ?? '—',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "المريض: ${procedure.patientName}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _AssuranceBadge(procedure: procedure),
            ],
          ),
          if (procedure.isEmergency || procedure.reliabilityFlags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (procedure.isEmergency)
                    const _Chip(
                      label: 'طارئ',
                      color: Color(0xFFC1483F),
                      bg: Color(0xFFFBECEB),
                    ),
                  ...procedure.reliabilityFlags.map(
                    (f) => _Chip(
                      label: ProcedureDisplay.flagLabel(f),
                      color: const Color(0xFFC1483F),
                      bg: const Color(0xFFFBECEB),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
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
                      _date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                Text(
                  ProcedureDisplay.statusLabel(procedure.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ProcedureDisplay.statusColor(procedure.status),
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

class _AssuranceBadge extends StatelessWidget {
  final Procedure procedure;

  const _AssuranceBadge({required this.procedure});

  @override
  Widget build(BuildContext context) {
    final level = procedure.assuranceLevel;
    final color = ProcedureDisplay.assuranceColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ProcedureDisplay.assuranceBg(level),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ProcedureDisplay.assuranceIcon(level), color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            procedure.reliabilityScore != null
                ? '${ProcedureDisplay.assuranceLabel(level)} · ${procedure.reliabilityScore}/10'
                : ProcedureDisplay.assuranceLabel(level),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _Chip({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
