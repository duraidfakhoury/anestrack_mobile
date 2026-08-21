import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/core/utils/relative_time.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_paper_comment.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_paper_detail_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/pdf_viewer_args.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/routes/pdf_viewer_route.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/blocs/research_paper_comments_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupervisorResearchPaperReviewScreen extends StatefulWidget {
  const SupervisorResearchPaperReviewScreen({
    super.key,
    required this.paperId,
    this.initialPaper,
  });

  final String paperId;
  final ResearchPaper? initialPaper;

  @override
  State<SupervisorResearchPaperReviewScreen> createState() =>
      _SupervisorResearchPaperReviewScreenState();
}

class _SupervisorResearchPaperReviewScreenState
    extends State<SupervisorResearchPaperReviewScreen> {
  late final ResearchPaperDetailBloc _detailBloc;
  late final ResearchPaperCommentsBloc _commentsBloc;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _detailBloc = sl<ResearchPaperDetailBloc>()
      ..add(FetchResearchPaperDetailEvent(widget.paperId));
    _commentsBloc = sl<ResearchPaperCommentsBloc>()
      ..add(FetchResearchPaperCommentsEvent(widget.paperId));
  }

  @override
  void dispose() {
    _detailBloc.close();
    _commentsBloc.close();
    _noteController.dispose();
    super.dispose();
  }

  void _sendNote() {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;
    _commentsBloc.add(
      SubmitResearchPaperCommentEvent(paperId: widget.paperId, content: content),
    );
    _noteController.clear();
    FocusScope.of(context).unfocus();
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
      body: BlocBuilder<ResearchPaperDetailBloc, BaseState<ResearchPaper>>(
        bloc: _detailBloc,
        builder: (context, detailState) {
          final paper = detailState.data ?? widget.initialPaper;
          if (paper == null) {
            if (detailState.isError) {
              return Center(child: Text(detailState.errorMessage));
            }
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _PaperInfoCard(paper: paper),
                    const SizedBox(height: 20),
                    Text(
                      LocaleKeys.supervisor_academic_notes_title.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<ResearchPaperCommentsBloc, ResearchPaperCommentsState>(
                      bloc: _commentsBloc,
                      builder: (context, state) {
                        if (state.isLoading || state.isInit) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final comments = state.data ?? const [];
                        if (comments.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                LocaleKeys.supervisor_academic_empty_notes.tr(),
                                style: const TextStyle(color: AppColors.slate400),
                              ),
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
              _NoteComposer(controller: _noteController, onSend: _sendNote),
            ],
          );
        },
      ),
    );
  }
}

class _PaperInfoCard extends StatelessWidget {
  const _PaperInfoCard({required this.paper});
  final ResearchPaper paper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paper.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
          if (paper.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              paper.description,
              style: const TextStyle(fontSize: 13, color: AppColors.slate600),
            ),
          ],
          if (paper.authors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(LucideIcons.users, size: 14, color: AppColors.slate500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    paper.authors.join('، '),
                    style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
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
                      extra: PdfViewerArgs(title: paper.title, url: paper.fileUrl!),
                    ),
              icon: const Icon(LucideIcons.fileDown, size: 16),
              label: Text(
                paper.fileUrl == null
                    ? LocaleKeys.library_pdf_not_available.tr()
                    : LocaleKeys.library_open_pdf.tr(),
              ),
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
                    color: AppColors.supervisorPrimary,
                  ),
                ),
              ),
              if (comment.createdAt != null)
                Text(
                  formatRelative(comment.createdAt!),
                  style: const TextStyle(fontSize: 10, color: AppColors.slate400),
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

class _NoteComposer extends StatelessWidget {
  const _NoteComposer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.gray100)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: LocaleKeys.supervisor_academic_add_note_hint.tr(),
                  filled: true,
                  fillColor: AppColors.slate50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onSend,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.supervisorPrimary,
                foregroundColor: AppColors.white,
              ),
              icon: const Icon(LucideIcons.send, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
