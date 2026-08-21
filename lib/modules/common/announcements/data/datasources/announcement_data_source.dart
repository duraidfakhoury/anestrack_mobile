import 'package:anestrack_mobile/modules/common/announcements/data/models/announcement_model.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/parameters/create_announcement_parameters.dart';

abstract class AnnouncementDataSource {
  Future<List<AnnouncementModel>> listAnnouncements({int? limit, int? skip});

  Future<AnnouncementModel> createAnnouncement(
    CreateAnnouncementParameters parameters,
  );
}
