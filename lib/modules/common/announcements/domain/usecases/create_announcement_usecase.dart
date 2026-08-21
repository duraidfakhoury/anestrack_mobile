import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/parameters/create_announcement_parameters.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/repositories/announcement_repository.dart';

class CreateAnnouncementUseCase {
  final AnnouncementRepository repository;

  CreateAnnouncementUseCase(this.repository);

  Future<Either<Failure, Announcement>> call(
    CreateAnnouncementParameters parameters,
  ) => repository.createAnnouncement(parameters);
}
