import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/routes/supervisor_research_paper_review_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupervisorResearchLibraryScreen extends StatefulWidget {
  const SupervisorResearchLibraryScreen({super.key});

  @override
  State<SupervisorResearchLibraryScreen> createState() =>
      _SupervisorResearchLibraryScreenState();
}

class _SupervisorResearchLibraryScreenState
    extends State<SupervisorResearchLibraryScreen> {
  late final ResearchBloc _researchBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _researchBloc = sl<ResearchBloc>()..add(FetchResearchPapersEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _researchBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _researchBloc.add(LoadMoreResearchPapersEvent());
    }
  }

  Future<void> _onRefresh() {
    _researchBloc.add(RefreshResearchPapersEvent());
    return _researchBloc.stream.firstWhere((state) => !state.isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.supervisorPrimary,
        foregroundColor: AppColors.white,
        title: Text(LocaleKeys.supervisor_academic_research_review_title.tr()),
      ),
      body: BlocBuilder<ResearchBloc, BaseState<List<ResearchPaper>>>(
        bloc: _researchBloc,
        builder: (context, state) {
          if (state.isLoading || state.isInit) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.circleAlert,
                      size: 44,
                      color: AppColors.red600,
                    ),
                    const SizedBox(height: 12),
                    Text(state.errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          _researchBloc.add(FetchResearchPapersEvent()),
                      child: Text(LocaleKeys.supervisor_academic_retry.tr()),
                    ),
                  ],
                ),
              ),
            );
          }
          final items = state.data ?? const [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      children: [
                        const Icon(
                          LucideIcons.bookOpen,
                          size: 44,
                          color: AppColors.slate400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          LocaleKeys.library_empty_papers.tr(),
                          style: const TextStyle(color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          final showLoadingMore = _researchBloc.hasMore;
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                for (final paper in items) ...[
                  _SupervisorPaperCard(paper: paper),
                  const SizedBox(height: 12),
                ],
                if (showLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SupervisorPaperCard extends StatelessWidget {
  const _SupervisorPaperCard({required this.paper});
  final ResearchPaper paper;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(
        '${SupervisorResearchPaperReviewRoute.name}/${paper.id}',
        extra: paper,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.purple100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.fileText,
                color: AppColors.purple600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                  if (paper.authors.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      paper.authors.join('، '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronLeft,
              size: 18,
              color: AppColors.slate400,
            ),
          ],
        ),
      ),
    );
  }
}
