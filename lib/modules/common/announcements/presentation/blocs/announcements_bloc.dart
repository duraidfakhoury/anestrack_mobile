import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/entities/announcement.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/usecases/list_announcements_usecase.dart';

abstract class AnnouncementsEvent {}

class FetchAnnouncementsEvent extends AnnouncementsEvent {}

typedef AnnouncementsState = BaseState<List<Announcement>>;

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final ListAnnouncementsUseCase listUseCase;

  AnnouncementsBloc(this.listUseCase)
    : super(const BaseState<List<Announcement>>()) {
    on<FetchAnnouncementsEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchAnnouncementsEvent event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(state.loading());
    final result = await listUseCase();
    result.fold(
      (failure) => emit(state.error(failure)),
      (items) => emit(state.successNotNull(items)),
    );
  }
}
