import 'package:anestrack_mobile/modules/common/profile/data/models/current_user_model.dart';

abstract class ProfileDataSource {
  Future<CurrentUserModel> getCurrentUser();
}
