import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/entities/app_notification.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/blocs/notifications_bloc.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/blocs/unread_count_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsBloc _notificationsBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _notificationsBloc = sl<NotificationsBloc>()
      ..add(FetchNotificationsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _notificationsBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _notificationsBloc.add(LoadMoreNotificationsEvent());
    }
  }

  Future<void> _onRefresh() {
    _notificationsBloc.add(RefreshNotificationsEvent());
    return _notificationsBloc.stream.firstWhere((state) => !state.isLoading);
  }

  void _markOne(String id) {
    _notificationsBloc.add(MarkNotificationReadEvent(id));
    sl<UnreadCountBloc>().add(FetchUnreadCountEvent());
  }

  void _markAll() {
    _notificationsBloc.add(MarkAllNotificationsReadEvent());
    sl<UnreadCountBloc>().add(FetchUnreadCountEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.studentPrimary,
        foregroundColor: AppColors.white,
        title: const Text('الإشعارات'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowRight),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _markAll,
            child: const Text(
              'تعليم الكل كمقروء',
              style: TextStyle(color: AppColors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, BaseState<List<AppNotification>>>(
        bloc: _notificationsBloc,
        builder: (context, state) {
          if (state.isLoading || state.isInit) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isError) {
            return _CenterMessage(
              icon: LucideIcons.circleAlert,
              color: AppColors.red600,
              message: state.errorMessage,
              onRetry: () =>
                  _notificationsBloc.add(FetchNotificationsEvent()),
            );
          }
          final items = state.data ?? const [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  _CenterMessage(
                    icon: LucideIcons.bellOff,
                    color: AppColors.slate400,
                    message: 'لا توجد إشعارات',
                  ),
                ],
              ),
            );
          }
          final showLoadingMore = _notificationsBloc.hasMore;
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: items.length + (showLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                return _NotificationTile(
                  notification: items[i],
                  onTap: () {
                    if (!items[i].isRead) _markOne(items[i].id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    final (icon, color) = _visualFor(notification.type);
    return Material(
      color: unread ? AppColors.blue100 : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                        color: AppColors.slate900,
                      ),
                    ),
                    if (notification.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (unread)
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 4),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.studentPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _visualFor(String? type) {
    switch (type) {
      case 'Approval':
        return (LucideIcons.circleCheck, AppColors.green);
      case 'Rejection':
        return (LucideIcons.circleX, AppColors.red600);
      case 'Announcement':
        return (LucideIcons.megaphone, AppColors.amber600);
      case 'Lecture':
        return (LucideIcons.graduationCap, AppColors.blue600);
      default:
        return (LucideIcons.bell, AppColors.studentPrimary);
    }
  }
}

class _CenterMessage extends StatelessWidget {
  const _CenterMessage({
    required this.icon,
    required this.color,
    required this.message,
    this.onRetry,
  });
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: color),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
