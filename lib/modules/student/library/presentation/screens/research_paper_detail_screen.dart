import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/core/utils/relative_time.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper_comment.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_paper_comments_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_paper_detail_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/pdf_viewer_args.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/pdf_viewer_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResearchPaperDetailScreen extends StatefulWidget {
  const ResearchPaperDetailScreen({
    super.key,
    required this.paperId,
    this.initialPaper,
  });

  final String paperId;
  final ResearchPaper? initialPaper;

  @override
  State<ResearchPaperDetailScreen> createState() =>
      _ResearchPaperDetailScreenState();
}

class _ResearchPaperDetailScreenState extends State<ResearchPaperDetailScreen> {
  late final ResearchPaperDetailBloc _bloc;
  late final ResearchPaperCommentsBloc _commentsBloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ResearchPaperDetailBloc>()
      ..add(FetchResearchPaperDetailEvent(widget.paperId));
    _commentsBloc = sl<ResearchPaperCommentsBloc>()
      ..add(FetchResearchPaperCommentsEvent(widget.paperId));
  }

  @override
  void dispose() {
    _bloc.close();
    _commentsBloc.close();
    super.dispose();
  }

  Future<void> _onRefresh() {
    _bloc.add(FetchResearchPaperDetailEvent(widget.paperId));
    _commentsBloc.add(FetchResearchPaperCommentsEvent(widget.paperId));
    return Future.wait([
      _bloc.stream.firstWhere((s) => !s.isLoading),
      _commentsBloc.stream.firstWhere((s) => !s.isLoading),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: BlocBuilder<ResearchPaperDetailBloc, BaseState<ResearchPaper>>(
        bloc: _bloc,
        builder: (context, state) {
          final paper = state.data ?? widget.initialPaper;
          if (paper == null) {
            if (state.isError) {
              return SafeArea(
                child: _ErrorView(
                  message: state.errorMessage,
                  onRetry: () =>
                      _bloc.add(FetchResearchPaperDetailEvent(widget.paperId)),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          return _DetailBody(
            paper: paper,
            commentsBloc: _commentsBloc,
            onRefresh: _onRefresh,
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.paper,
    required this.commentsBloc,
    required this.onRefresh,
  });
  final ResearchPaper paper;
  final ResearchPaperCommentsBloc commentsBloc;
  final Future<void> Function() onRefresh;

  String? get _formattedDate {
    final raw = paper.publishedAt;
    if (raw == null) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return DateFormat('yyyy/MM/dd').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 56,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.studentPrimary,
                    AppColors.studentPrimaryDark,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          LucideIcons.arrowRight,
                          color: AppColors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          LocaleKeys.library_detail_title.tr(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      LucideIcons.fileText,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    paper.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(
              children: [
                if (paper.description.isNotEmpty)
                  Text(
                    paper.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate600,
                      height: 1.6,
                    ),
                  ),
                const SizedBox(height: 16),
                if (paper.authors.isNotEmpty)
                  _InfoRow(
                    icon: LucideIcons.users,
                    label: LocaleKeys.library_authors_label.tr(),
                    value: paper.authors.join('، '),
                  ),
                if (paper.researchTypeName != null)
                  _InfoRow(
                    icon: LucideIcons.tag,
                    label: LocaleKeys.library_type_label.tr(),
                    value: paper.researchTypeName!,
                  ),
                if (_formattedDate != null)
                  _InfoRow(
                    icon: LucideIcons.calendar,
                    label: LocaleKeys.library_published_at_label.tr(),
                    value: _formattedDate!,
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue600,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: paper.fileUrl == null
                        ? null
                        : () => context.push(
                            PdfViewerRoute.name,
                            extra: PdfViewerArgs(
                              title: paper.title,
                              url: paper.fileUrl!,
                            ),
                          ),
                    icon: const Icon(LucideIcons.fileDown, size: 16),
                    label: Text(
                      paper.fileUrl == null
                          ? LocaleKeys.library_pdf_not_available.tr()
                          : LocaleKeys.library_open_pdf.tr(),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  LocaleKeys.library_notes_title.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 12),
                BlocBuilder<
                  ResearchPaperCommentsBloc,
                  ResearchPaperCommentsState
                >(
                  bloc: commentsBloc,
                  builder: (context, state) {
                    if (state.isLoading || state.isInit) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final comments = state.data ?? const [];
                    if (comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          LocaleKeys.library_empty_notes.tr(),
                          style: const TextStyle(color: AppColors.slate400),
                        ),
                      );
                    }
                    return Column(
                      children: comments
                          .map((c) => _CommentTile(comment: c))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final ResearchPaperComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.studentPrimary,
                  ),
                ),
              ),
              if (comment.createdAt != null)
                Text(
                  formatRelative(comment.createdAt!),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.slate400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 13, color: AppColors.slate700),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.slate500),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.slate600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.slate600),
            ),
          ),
        ],
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
            const Icon(
              LucideIcons.circleAlert,
              size: 44,
              color: AppColors.red600,
            ),
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
