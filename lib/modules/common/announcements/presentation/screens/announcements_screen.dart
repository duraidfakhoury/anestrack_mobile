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

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnnouncementsBloc>()..add(FetchAnnouncementsEvent()),
      child: Scaffold(
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
          builder: (context, state) {
            if (state.isLoading || state.isInit) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.isError) {
              return _ErrorView(
                message: state.errorMessage,
                onRetry: () => context
                    .read<AnnouncementsBloc>()
                    .add(FetchAnnouncementsEvent()),
              );
            }
            final items = state.data ?? const [];
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.megaphone, size: 44, color: AppColors.slate400),
                      SizedBox(height: 12),
                      Text('لا توجد إعلانات'),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<AnnouncementsBloc>()
                  .add(FetchAnnouncementsEvent()),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => AnnouncementCard(item: items[i]),
              ),
            );
          },
        ),
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

/// Lightweight relative-time label without extra dependencies.
String formatRelative(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
  if (diff.inDays == 1) return 'أمس';
  if (diff.inDays < 30) return 'منذ ${diff.inDays} يوم';
  final d = date.toLocal();
  return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
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
