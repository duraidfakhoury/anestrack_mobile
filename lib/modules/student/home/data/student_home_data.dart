import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/home/domain/entities/student_home_tile.dart';

class StudentHomeData {
  static const tiles = [
    StudentHomeTile(
      title: LocaleKeys.viewanestrack_mobiles,
      subtitle: 'Track your anestrack_mobile updates',
      iconKey: 'anestrack_mobiles',
      colorValue: 0xFF0D9488,
    ),
    StudentHomeTile(
      title: LocaleKeys.addanestrack_mobile,
      subtitle: 'Send a new anestrack_mobile quickly',
      iconKey: 'add',
      colorValue: 0xFF0891B2,
    ),
    StudentHomeTile(
      title: LocaleKeys.profile,
      subtitle: 'Update your student profile',
      iconKey: 'profile',
      colorValue: 0xFF2563EB,
    ),
    StudentHomeTile(
      title: LocaleKeys.settings,
      subtitle: 'Preferences and language',
      iconKey: 'settings',
      colorValue: 0xFFF59E0B,
    ),
  ];
}
