import 'package:equatable/equatable.dart';

enum RecentActivityType { lecture, research, announcement }

/// A single entry in the supervisor academic hub's "recent activity" feed,
/// built client-side from the latest lecture / research paper / announcement.
class RecentActivityItem extends Equatable {
  final RecentActivityType type;
  final String title;
  final String? timestamp;

  const RecentActivityItem({
    required this.type,
    required this.title,
    this.timestamp,
  });

  @override
  List<Object?> get props => [type, title, timestamp];
}
