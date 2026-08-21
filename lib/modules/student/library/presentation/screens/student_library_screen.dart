import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/core_components/show_toast.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/publish_research_route.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/research_paper_detail_route.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/utils/pdf_bytes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';

class StudentLibraryScreen extends StatefulWidget {
  const StudentLibraryScreen({super.key});

  @override
  State<StudentLibraryScreen> createState() => _StudentLibraryScreenState();
}

class _StudentLibraryScreenState extends State<StudentLibraryScreen> {
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

  Future<void> _onPublishPressed() async {
    final published = await context.push<bool>(PublishResearchRoute.name);
    if (published == true) {
      _researchBloc.add(RefreshResearchPapersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: BlocBuilder<ResearchBloc, BaseState<List<ResearchPaper>>>(
        bloc: _researchBloc,
        builder: (context, state) {
          final items = state.data ?? const [];
          return Column(
            children: [
              _Header(paperCount: items.length, onPublish: _onPublishPressed),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading || state.isInit) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.isError) {
                      return _ErrorView(
                        message: state.errorMessage,
                        onRetry: () =>
                            _researchBloc.add(FetchResearchPapersEvent()),
                      );
                    }
                    if (items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _EmptyView(
                              icon: LucideIcons.bookOpen,
                              message: LocaleKeys.library_empty_papers.tr(),
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
                          const _CouncilReportBanner(),
                          const SizedBox(height: 16),
                          Text(
                            LocaleKeys.library_papers_section_title.tr(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final paper in items) ...[
                            _PaperCard(paper: paper),
                            const SizedBox(height: 12),
                          ],
                          if (showLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.paperCount, required this.onPublish});
  final int paperCount;
  final VoidCallback onPublish;

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
            LocaleKeys.library_title.tr(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.library_papers_available.tr(
              args: [paperCount.toString()],
            ),
            style: const TextStyle(
              color: AppColors.studentPrimaryLight,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.15),
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              onPressed: onPublish,
              icon: const Icon(LucideIcons.upload, size: 18),
              label: Text(
                LocaleKeys.library_publish_research.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouncilReportBanner extends StatelessWidget {
  const _CouncilReportBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.fileText, color: AppColors.blue600, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.library_council_report_title.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.library_council_report_body.tr(),
                  style: const TextStyle(fontSize: 12, color: AppColors.blue600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({required this.paper});
  final ResearchPaper paper;

  String? get _formattedDate {
    final raw = paper.publishedAt;
    if (raw == null) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return DateFormat('yyyy/MM/dd').format(parsed);
  }

  Future<void> _downloadPdf(ResearchPaper paper) async {
    try {
      final bytes = await fetchPdfBytes(paper.fileUrl!);
      await Printing.sharePdf(bytes: bytes, filename: '${paper.title}.pdf');
    } catch (_) {
      showToast(LocaleKeys.library_pdf_viewer_error.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  paper.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
              ),
            ],
          ),
          if (paper.authors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(LucideIcons.users, size: 14, color: AppColors.slate500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    paper.authors.join('، '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.slate500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_formattedDate != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: AppColors.slate500,
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedDate!,
                  style: const TextStyle(fontSize: 11, color: AppColors.slate500),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.blue100,
                    foregroundColor: AppColors.blue600,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: paper.fileUrl == null
                      ? null
                      : () => _downloadPdf(paper),
                  icon: const Icon(LucideIcons.download, size: 14),
                  label: Text(
                    LocaleKeys.library_download_pdf.tr(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.studentPrimaryLight,
                    foregroundColor: AppColors.studentPrimary,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => context.push(
                    '${ResearchPaperDetailRoute.name}/${paper.id}',
                    extra: paper,
                  ),
                  icon: const Icon(LucideIcons.eye, size: 14),
                  label: Text(
                    LocaleKeys.library_view.tr(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.slate400),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppColors.slate500)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleAlert, size: 44, color: AppColors.red600),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(LocaleKeys.library_retry.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
