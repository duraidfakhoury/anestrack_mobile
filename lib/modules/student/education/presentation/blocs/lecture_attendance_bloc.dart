import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/education/domain/entities/lecture_attendance.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/lecture_attendance_usecases.dart';

abstract class LectureAttendanceEvent {}

/// Record (or look up) attendance when the student opens the lecture.
class OpenLectureAttendanceEvent extends LectureAttendanceEvent {
  final String lectureId;
  OpenLectureAttendanceEvent(this.lectureId);
}

/// Mark the current attendance row completed when the student finishes.
class CompleteLectureAttendanceEvent extends LectureAttendanceEvent {}

/// Attendance is best-effort — the lecture screen renders regardless of this
/// state. [data] holds the current student's row once ensured.
typedef LectureAttendanceState = BaseState<LectureAttendance?>;

class LectureAttendanceBloc
    extends Bloc<LectureAttendanceEvent, LectureAttendanceState> {
  final EnsureAttendanceUseCase ensureAttendanceUseCase;
  final MarkAttendanceCompletedUseCase markCompletedUseCase;

  LectureAttendanceBloc(
    this.ensureAttendanceUseCase,
    this.markCompletedUseCase,
  ) : super(const BaseState<LectureAttendance?>()) {
    on<OpenLectureAttendanceEvent>(_onOpen);
    on<CompleteLectureAttendanceEvent>(_onComplete);
  }

  Future<void> _onOpen(
    OpenLectureAttendanceEvent event,
    Emitter<LectureAttendanceState> emit,
  ) async {
    // Only students are tracked for attendance.
    if (CacheService().userRole != 'Student') return;
    emit(state.loading());
    final result = await ensureAttendanceUseCase(
      lectureId: event.lectureId,
      studentId: CacheService().userId,
    );
    result.fold(
      (failure) => emit(state.error(failure)),
      (attendance) => emit(state.success(attendance)),
    );
  }

  Future<void> _onComplete(
    CompleteLectureAttendanceEvent event,
    Emitter<LectureAttendanceState> emit,
  ) async {
    final current = state.data;
    if (current == null || current.completed) return;
    final result = await markCompletedUseCase(current.id);
    result.fold(
      (_) {},
      (attendance) => emit(state.success(attendance)),
    );
  }
}
