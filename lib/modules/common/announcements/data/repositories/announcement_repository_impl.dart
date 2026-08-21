import 'package:dartz/dartz.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/modules/common/announcements/data/datasources/announcement_data_source.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/parameters/create_announcement_parameters.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/repositories/announcement_repository.dart';

class AnnouncementRepositoryImpl extends AnnouncementRepository {
  final AnnouncementDataSource dataSource;

  AnnouncementRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Announcement>>> listAnnouncements({
    int? limit,
    int? skip,
  }) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.listAnnouncements(limit: limit, skip: skip),
    );
  }

  @override
  Future<Either<Failure, Announcement>> createAnnouncement(
    CreateAnnouncementParameters parameters,
  ) {
    return AppErrorsHandler().defaultHandleEither(
      () => dataSource.createAnnouncement(parameters),
    );
  }
}
