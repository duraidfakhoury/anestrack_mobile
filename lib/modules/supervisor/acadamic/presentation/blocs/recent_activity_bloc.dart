import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/usecases/list_announcements_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/list_lectures_usecase.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/list_research_papers_usecase.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/domain/entities/recent_activity_item.dart';

abstract class RecentActivityEvent {}

class FetchRecentActivityEvent extends RecentActivityEvent {}

typedef RecentActivityState = BaseState<List<RecentActivityItem>>;

/// Combines the single most recent lecture, research paper, and announcement
/// into one feed — there's no dedicated "recent activity" endpoint, so this
/// is assembled client-side from the 3 existing list endpoints.
class RecentActivityBloc extends Bloc<RecentActivityEvent, RecentActivityState> {
  final ListLecturesUseCase listLecturesUseCase;
  final ListResearchPapersUseCase listResearchPapersUseCase;
  final ListAnnouncementsUseCase listAnnouncementsUseCase;
  final Logger _logger = Logger();

  RecentActivityBloc(
    this.listLecturesUseCase,
    this.listResearchPapersUseCase,
    this.listAnnouncementsUseCase,
  ) : super(const BaseState<List<RecentActivityItem>>()) {
    on<FetchRecentActivityEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchRecentActivityEvent event,
    Emitter<RecentActivityState> emit,
  ) async {
    emit(state.loading());

    // Started concurrently (not awaited individually until below).
    final lecturesFuture = listLecturesUseCase(limit: 1, skip: 0);
    final papersFuture = listResearchPapersUseCase(limit: 1, skip: 0);
    final announcementsFuture = listAnnouncementsUseCase(limit: 1, skip: 0);

    final items = <RecentActivityItem>[];
    Failure? lastFailure;

    (await lecturesFuture).fold((f) => lastFailure = f, (lectures) {
      if (lectures.isNotEmpty) {
        final lecture = lectures.first;
        items.add(
          RecentActivityItem(
            type: RecentActivityType.lecture,
            title: lecture.title,
            timestamp: lecture.createdAt,
          ),
        );
      }
    });

    (await papersFuture).fold((f) => lastFailure = f, (papers) {
      if (papers.isNotEmpty) {
        final paper = papers.first;
        items.add(
          RecentActivityItem(
            type: RecentActivityType.research,
            title: paper.title,
            timestamp: paper.publishedAt,
          ),
        );
      }
    });

    (await announcementsFuture).fold((f) => lastFailure = f, (announcements) {
      if (announcements.isNotEmpty) {
        final announcement = announcements.first;
        items.add(
          RecentActivityItem(
            type: RecentActivityType.announcement,
            title: announcement.title,
            timestamp: announcement.createdAt,
          ),
        );
      }
    });

    if (items.isEmpty && lastFailure != null) {
      _logger.e('Failed to fetch recent activity: ${lastFailure!.message}');
      emit(state.error(lastFailure!));
      return;
    }

    items.sort((a, b) {
      if (a.timestamp == null) return 1;
      if (b.timestamp == null) return -1;
      return b.timestamp!.compareTo(a.timestamp!);
    });

    emit(state.successNotNull(items));
  }
}
