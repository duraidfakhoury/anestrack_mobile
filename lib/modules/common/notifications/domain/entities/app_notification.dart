import 'package:equatable/equatable.dart';

/// A single user notification (`Notification` Parse class).
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final String? type; // Approval | Rejection | Announcement | Lecture
  final bool isRead;
  final String? createdAt; // ISO string

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.isRead = false,
    this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    message: message,
    type: type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, title, message, type, isRead, createdAt];
}
