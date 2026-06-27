import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/entities/supervisor_home_tile.dart';

class SupervisorHomeData {
  static const tiles = [
    SupervisorHomeTile(
      title: LocaleKeys.viewanestrack_mobiles,
      subtitle: 'Review incoming anestrack_mobiles',
      iconKey: 'anestrack_mobiles',
      colorValue: 0xFF0F766E,
    ),
    SupervisorHomeTile(
      title: 'Manage Students',
      subtitle: 'Track assigned student progress',
      iconKey: 'students',
      colorValue: 0xFF6366F1,
    ),
    SupervisorHomeTile(
      title: LocaleKeys.profile,
      subtitle: 'Supervisor profile and availability',
      iconKey: 'profile',
      colorValue: 0xFF2563EB,
    ),
    SupervisorHomeTile(
      title: LocaleKeys.settings,
      subtitle: 'Notifications and preferences',
      iconKey: 'settings',
      colorValue: 0xFFF59E0B,
    ),
  ];
}
