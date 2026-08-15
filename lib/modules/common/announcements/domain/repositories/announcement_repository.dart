import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<Either<Failure, List<Announcement>>> listAnnouncements();
}
