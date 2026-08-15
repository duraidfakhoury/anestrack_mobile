import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/entities/current_user.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/usecases/get_current_user_usecase.dart';

abstract class CurrentUserEvent {}

class FetchCurrentUserEvent extends CurrentUserEvent {}

typedef CurrentUserState = BaseState<CurrentUser>;

/// Loads the authenticated user (`getCurrentUser`) for headers/profile screens.
class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUserState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final Logger _logger = Logger();

  CurrentUserBloc(this.getCurrentUserUseCase)
    : super(const BaseState<CurrentUser>()) {
    on<FetchCurrentUserEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchCurrentUserEvent event,
    Emitter<CurrentUserState> emit,
  ) async {
    emit(state.loading());
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        _logger.e('Failed to fetch current user: ${failure.message}');
        emit(state.error(failure));
      },
      (user) => emit(state.successNotNull(user)),
    );
  }
}
