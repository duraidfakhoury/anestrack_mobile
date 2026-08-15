import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/repositories/announcement_repository.dart';

class ListAnnouncementsUseCase {
  final AnnouncementRepository repository;

  ListAnnouncementsUseCase(this.repository);

  Future<Either<Failure, List<Announcement>>> call() =>
      repository.listAnnouncements();
}
