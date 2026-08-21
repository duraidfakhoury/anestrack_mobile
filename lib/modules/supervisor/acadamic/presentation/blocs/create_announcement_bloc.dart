import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/parameters/create_announcement_parameters.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/usecases/create_announcement_usecase.dart';

abstract class CreateAnnouncementEvent {}

class SubmitCreateAnnouncementEvent extends CreateAnnouncementEvent {
  final CreateAnnouncementParameters parameters;
  SubmitCreateAnnouncementEvent(this.parameters);
}

typedef CreateAnnouncementState = BaseState<Announcement>;

class CreateAnnouncementBloc
    extends Bloc<CreateAnnouncementEvent, CreateAnnouncementState> {
  final CreateAnnouncementUseCase createAnnouncementUseCase;
  final Logger _logger = Logger();

  CreateAnnouncementBloc(this.createAnnouncementUseCase)
    : super(const BaseState<Announcement>()) {
    on<SubmitCreateAnnouncementEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitCreateAnnouncementEvent event,
    Emitter<CreateAnnouncementState> emit,
  ) async {
    emit(state.loading());
    final result = await createAnnouncementUseCase(event.parameters);
    result.fold(
      (failure) {
        _logger.e('Failed to create announcement: ${failure.message}');
        emit(state.error(failure));
      },
      (announcement) {
        _logger.i('Created announcement ${announcement.objectId}');
        emit(state.successNotNull(announcement));
      },
    );
  }
}
