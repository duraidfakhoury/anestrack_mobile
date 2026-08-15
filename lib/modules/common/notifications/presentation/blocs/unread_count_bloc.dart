import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/usecases/notification_usecases.dart';

abstract class UnreadCountEvent {}

class FetchUnreadCountEvent extends UnreadCountEvent {}

typedef UnreadCountState = BaseState<int>;

/// Small bloc powering the notification bell badge.
class UnreadCountBloc extends Bloc<UnreadCountEvent, UnreadCountState> {
  final GetUnreadCountUseCase getUnreadCountUseCase;

  UnreadCountBloc(this.getUnreadCountUseCase)
    : super(const BaseState<int>()) {
    on<FetchUnreadCountEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchUnreadCountEvent event,
    Emitter<UnreadCountState> emit,
  ) async {
    final result = await getUnreadCountUseCase();
    result.fold(
      (failure) => emit(state.error(failure)),
      (count) => emit(state.successNotNull(count)),
    );
  }
}
