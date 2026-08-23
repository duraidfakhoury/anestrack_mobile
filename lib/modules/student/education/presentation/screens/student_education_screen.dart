import 'dart:async';

import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lectures_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_detail_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/routes/lecture_quiz_route.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_ai_summary_sheet.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const List<String?> _kContentTypeFilters = [null, 'Video', 'Document', 'Text'];

class StudentEducationScreen extends StatefulWidget {
  const StudentEducationScreen({super.key});

  @override
  State<StudentEducationScreen> createState() =>
      _StudentEducationScreenState();
}

class _StudentEducationScreenState extends State<StudentEducationScreen> {
  late final LecturesBloc _lecturesBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _contentTypeFilter;

  @override
  void initState() {
    super.initState();
    _lecturesBloc = sl<LecturesBloc>()..add(FetchLecturesEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _lecturesBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _lecturesBloc.add(LoadMoreLecturesEvent());
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (value.trim().isEmpty) {
        _lecturesBloc.add(ClearSearchEvent());
      } else {
        _lecturesBloc.add(SearchLecturesEvent(value));
      }
    });
  }

  Future<void> _onRefresh() {
    _lecturesBloc.add(RefreshLecturesEvent());
    return _lecturesBloc.stream.firstWhere((state) => !state.isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Column(
        children: [
          _Header(
            title: LocaleKeys.nav_education.tr(),
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
          ),
          _ContentTypeChips(
            selected: _contentTypeFilter,
            onSelected: (value) => setState(() => _contentTypeFilter = value),
          ),
          Expanded(
            child: BlocBuilder<LecturesBloc, BaseState<List<Lecture>>>(
              bloc: _lecturesBloc,
              builder: (context, state) {
                if (state.isLoading || state.isInit) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.isError) {
                  return LectureErrorView(
                    message: state.errorMessage,
                    onRetry: () => _lecturesBloc.add(FetchLecturesEvent()),
                  );
                }
                final allItems = state.data ?? const [];
                final items = _contentTypeFilter == null
                    ? allItems
                    : allItems
                        .where((l) => l.contentType == _contentTypeFilter)
                        .toList();
                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        LectureEmptyView(
                          icon: LucideIcons.graduationCap,
                          message: LocaleKeys.education_empty_lectures.tr(),
                        ),
                      ],
                    ),
                  );
                }
                final showLoadingMore = _lecturesBloc.hasMore;
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length + (showLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i >= items.length) {
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
                      return _LectureCard(lecture: items[i]);
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
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.searchController,
    required this.onSearchChanged,
  });

  final String title;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.studentPrimary, AppColors.studentPrimaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(color: AppColors.slate900, fontSize: 13),
            decoration: InputDecoration(
              hintText: LocaleKeys.education_search_hint.tr(),
              hintStyle: const TextStyle(color: AppColors.slate500, fontSize: 13),
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.slate500, size: 18),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
}

class _ContentTypeChips extends StatelessWidget {
  const _ContentTypeChips({required this.selected, required this.onSelected});
  final String? selected;
  final ValueChanged<String?> onSelected;

  String _label(String? value) {
    switch (value) {
      case null:
        return LocaleKeys.education_filter_all.tr();
      case 'Video':
        return LocaleKeys.education_filter_video.tr();
      case 'Document':
        return LocaleKeys.education_filter_document.tr();
      case 'Text':
        return LocaleKeys.education_filter_text.tr();
      default:
        return value;
    }
  }

  IconData? _icon(String? value) {
    switch (value) {
      case 'Video':
        return LucideIcons.play;
      case 'Document':
        return LucideIcons.fileText;
      case 'Text':
        return LucideIcons.alignLeft;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _kContentTypeFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final value = _kContentTypeFilters[i];
          final isSelected = value == selected;
          final icon = _icon(value);
          return ChoiceChip(
            label: Text(_label(value)),
            avatar: icon != null ? Icon(icon, size: 14) : null,
            selected: isSelected,
            onSelected: (_) => onSelected(value),
            selectedColor: AppColors.studentPrimary,
            backgroundColor: AppColors.white,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.white : AppColors.slate700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.studentPrimary : AppColors.gray200,
            ),
          );
        },
      ),
    );
  }
}

class _LectureCard extends StatelessWidget {
  const _LectureCard({required this.lecture});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = lectureContentTypeVisual(lecture.contentType);
    final typeLabel = lectureContentTypeLabel(lecture.contentType);
    final dateLabel = lecture.createdAt != null
        ? DateFormat.yMMMd(context.locale.languageCode).format(
            DateTime.tryParse(lecture.createdAt!) ?? DateTime.now(),
          )
        : null;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          '${LectureDetailRoute.name}/${lecture.id}',
          extra: lecture,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lecture.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                ],
              ),
              if (typeLabel.isNotEmpty || dateLabel != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (typeLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (typeLabel.isNotEmpty && dateLabel != null)
                      const SizedBox(width: 8),
                    if (dateLabel != null)
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.slate500,
                        ),
                      ),
                  ],
                ),
              ],
              if (lecture.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  lecture.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.slate600),
                ),
              ],
              if (lecture.mainGoals.isNotEmpty) ...[
                const SizedBox(height: 12),
                LectureMainGoalsList(goals: lecture.mainGoals),
              ],
              if (kAiSummaryFeatureEnabled) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue600,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => showLectureAiSummarySheet(
                      context,
                      lectureId: lecture.id,
                      lectureTitle: lecture.title,
                    ),
                    icon: const Icon(LucideIcons.fileText, size: 14),
                    label: Text(
                      LocaleKeys.education_ai_summary.tr(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
              if (lecture.withTest) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.studentPrimary,
                      side: const BorderSide(color: AppColors.studentPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => context.push(
                      '${LectureQuizRoute.name}/${lecture.id}',
                    ),
                    icon: const Icon(LucideIcons.clipboardCheck, size: 14),
                    label: Text(
                      LocaleKeys.education_start_quiz.tr(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
