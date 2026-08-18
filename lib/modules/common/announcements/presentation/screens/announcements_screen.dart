import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/core/utils/relative_time.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';
import 'package:anestrack_mobile/modules/common/announcements/presentation/blocs/announcements_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final AnnouncementsBloc _announcementsBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _announcementsBloc = sl<AnnouncementsBloc>()
      ..add(FetchAnnouncementsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _announcementsBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _announcementsBloc.add(LoadMoreAnnouncementsEvent());
    }
  }

  Future<void> _onRefresh() {
    _announcementsBloc.add(RefreshAnnouncementsEvent());
    return _announcementsBloc.stream.firstWhere((state) => !state.isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.studentPrimary,
        foregroundColor: AppColors.white,
        title: const Text('الإعلانات'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowRight),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AnnouncementsBloc, BaseState<List<Announcement>>>(
        bloc: _announcementsBloc,
        builder: (context, state) {
          if (state.isLoading || state.isInit) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isError) {
            return _ErrorView(
              message: state.errorMessage,
              onRetry: () =>
                  _announcementsBloc.add(FetchAnnouncementsEvent()),
            );
          }
          final items = state.data ?? const [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.megaphone,
                          size: 44,
                          color: AppColors.slate400,
                        ),
                        SizedBox(height: 12),
                        Text('لا توجد إعلانات'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          final showLoadingMore = _announcementsBloc.hasMore;
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
                return AnnouncementCard(item: items[i]);
              },
            ),
          );
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.item});
  final Announcement item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: item.isImportant
            ? const Border(right: BorderSide(color: AppColors.red600, width: 4))
            : Border.all(color: AppColors.gray100),
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
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: item.isImportant
                        ? AppColors.red600
                        : AppColors.slate900,
                  ),
                ),
              ),
              if (item.isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.red100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'مهم',
                    style: TextStyle(
                      color: AppColors.red600,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (item.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.content,
              style: const TextStyle(fontSize: 12, color: AppColors.slate600),
            ),
          ],
          if (item.createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              formatRelative(item.createdAt!),
              style: const TextStyle(fontSize: 11, color: AppColors.slate400),
            ),
          ],
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
            const Icon(LucideIcons.circleAlert, size: 44, color: AppColors.red600),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
