import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/entities/student.dart';
import 'package:anestrack_mobile/modules/supervisor/students/presentation/blocs/students_bloc/students_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupervisorStudentsScreen extends StatefulWidget {
  const SupervisorStudentsScreen({super.key});

  @override
  State<SupervisorStudentsScreen> createState() =>
      _SupervisorStudentsScreenState();
}

class _SupervisorStudentsScreenState extends State<SupervisorStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final StudentsBloc _studentsBloc;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _studentsBloc = sl<StudentsBloc>()..add(FetchStudentsEvent());
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _studentsBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _studentsBloc.add(LoadMoreStudentsEvent());
    }
  }

  void _refresh() => _studentsBloc.add(RefreshStudentsEvent());

  Future<void> _onRefresh() {
    _refresh();
    return _studentsBloc.stream.firstWhere((state) => !state.isLoading);
  }

  List<Student> _filteredStudents(List<Student> students) {
    if (_query.isEmpty) return students;
    final lowerQuery = _query.toLowerCase();
    return students
        .where(
          (student) =>
              _displayName(student).toLowerCase().contains(lowerQuery) ||
              student.username.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  static String _displayName(Student student) {
    final composed = '${student.firstName} ${student.lastName}'.trim();
    return composed.isNotEmpty ? composed : student.username;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.slate50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<StudentsBloc, StudentsState>(
              bloc: _studentsBloc,
              builder: (context, state) {
                if (state.isLoading || state.isInit) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.isError) {
                  return _ErrorView(
                    onRetry: _refresh,
                    message: state.errorMessage,
                  );
                }
                final students = _filteredStudents(state.data ?? []);
                if (students.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [_buildEmptyState(context)],
                    ),
                  );
                }
                final showLoadingMore =
                    _query.isEmpty && _studentsBloc.hasMore;
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: students.length + (showLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= students.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return _StudentCard(student: students[index]);
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, right: 20, left: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.indigo800, AppColors.indigo900],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'supervisor_students.title'.tr(context: context),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.white),
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              hintText: 'supervisor_students.search_hint'.tr(
                context: context,
              ),
              hintStyle: const TextStyle(color: AppColors.indigo200),
              prefixIcon: const Icon(
                LucideIcons.search,
                color: AppColors.indigo200,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.12),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.userX, size: 48, color: AppColors.slate400),
          const SizedBox(height: 16),
          Text(
            'supervisor_students.no_results'.tr(context: context),
            style: const TextStyle(color: AppColors.slate500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const _ErrorView({required this.onRetry, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.circleAlert,
              size: 48,
              color: AppColors.red600,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.slate500, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text('submit'.tr())),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;

  const _StudentCard({required this.student});

  String get _displayName {
    final composed = '${student.firstName} ${student.lastName}'.trim();
    return composed.isNotEmpty ? composed : student.username;
  }

  String get _secondaryLine =>
      student.mobileNumber.isNotEmpty
          ? student.mobileNumber
          : student.nationalId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _YearBadge(yearCode: student.yearCode),
                    if (student.isBlocked) const _BlockedBadge(),
                  ],
                ),
                if (_secondaryLine.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _secondaryLine,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            LucideIcons.chevronLeft,
            color: AppColors.slate400,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.purple100,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        LucideIcons.user,
        color: AppColors.supervisorPrimary,
        size: 22,
      ),
    );
  }
}

class _BlockedBadge extends StatelessWidget {
  const _BlockedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.red100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'supervisor_students.blocked'.tr(context: context),
        style: const TextStyle(
          color: AppColors.red600,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _YearBadge extends StatelessWidget {
  final int yearCode;

  const _YearBadge({required this.yearCode});

  static const _yearKeys = {
    1: 'supervisor_students.year.first',
    2: 'supervisor_students.year.second',
    3: 'supervisor_students.year.third',
    4: 'supervisor_students.year.fourth',
  };

  @override
  Widget build(BuildContext context) {
    final labelKey = _yearKeys[yearCode] ?? _yearKeys[1]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labelKey.tr(context: context),
        style: const TextStyle(
          color: AppColors.slate700,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
