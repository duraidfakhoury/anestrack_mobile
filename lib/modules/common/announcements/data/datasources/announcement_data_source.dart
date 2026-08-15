import 'package:anestrack_mobile/modules/common/announcements/data/models/announcement_model.dart';

abstract class AnnouncementDataSource {
  Future<List<AnnouncementModel>> listAnnouncements();
}
