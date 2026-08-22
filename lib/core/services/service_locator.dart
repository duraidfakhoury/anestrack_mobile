import 'package:anestrack_mobile/core/services/ble/supervisor_code_ble_scanner.dart';
import 'package:anestrack_mobile/core/services/ble/student_code_ble_advertiser.dart';
import 'package:anestrack_mobile/core/services/connectivity/connectivity_service.dart';
import 'package:anestrack_mobile/core/services/procedure_sync/procedure_sync_service.dart';
import 'package:anestrack_mobile/core/themes/bloc/theme_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:anestrack_mobile/modules/auth/data/data_soure/auth_data_source.dart';
import 'package:anestrack_mobile/modules/auth/data/data_soure/auth_data_source_impl.dart';
import 'package:anestrack_mobile/modules/auth/data/repository/auth_repository_impl.dart';
import 'package:anestrack_mobile/modules/auth/domain/repository/auth_repository.dart';
import 'package:anestrack_mobile/modules/auth/presentation/blocs/login_bloc/login_bloc.dart';
import 'package:anestrack_mobile/modules/auth/presentation/blocs/logout_bloc/logout_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/procedure_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/procedure_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/hospital_procedure_type_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/pending_procedure_local_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/pending_procedure_local_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/reference_data_local_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/reference_data_local_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/repositories/procedure_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/repositories/hospital_procedure_type_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/repositories/pending_procedure_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/hospital_procedure_type_repository.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/pending_procedure_repository.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/create_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/enqueue_offline_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_pending_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/sync_pending_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/co_sign_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/get_co_sign_context_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/confirm_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/create_evaluation_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_pending_for_supervisor_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_hospitals_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_procedure_types_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_supervisors_usecase.dart';
import 'package:anestrack_mobile/modules/supervisor/home/data/datasources/supervisor_dashboard_data_source.dart';
import 'package:anestrack_mobile/modules/supervisor/home/data/datasources/supervisor_dashboard_data_source_impl.dart';
import 'package:anestrack_mobile/modules/supervisor/home/data/repositories/supervisor_dashboard_repository_impl.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/repositories/supervisor_dashboard_repository.dart';
import 'package:anestrack_mobile/modules/supervisor/home/domain/usecases/get_supervisor_dashboard_usecase.dart';
import 'package:anestrack_mobile/modules/supervisor/home/presentation/blocs/dashboard_bloc/dashboard_bloc.dart';
import 'package:anestrack_mobile/modules/student/home/data/datasources/student_dashboard_data_source.dart';
import 'package:anestrack_mobile/modules/student/home/data/datasources/student_dashboard_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/home/data/repositories/student_dashboard_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/home/domain/repositories/student_dashboard_repository.dart';
import 'package:anestrack_mobile/modules/student/home/domain/usecases/get_student_dashboard_usecase.dart';
import 'package:anestrack_mobile/modules/student/home/presentation/blocs/student_dashboard_bloc/student_dashboard_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/co_sign_ble_bloc/co_sign_ble_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/hospitals_bloc/hospitals_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedure_types_bloc/procedure_types_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/supervisors_bloc/supervisors_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/pending_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_context_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/confirm_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/evaluation_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/live_co_sign_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/students/data/datasources/student_data_source.dart';
import 'package:anestrack_mobile/modules/supervisor/students/data/datasources/student_data_source_impl.dart';
import 'package:anestrack_mobile/modules/supervisor/students/data/repositories/student_repository_impl.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/repositories/student_repository.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/usecases/list_students_usecase.dart';
import 'package:anestrack_mobile/modules/supervisor/students/presentation/blocs/students_bloc/students_bloc.dart';
import 'package:anestrack_mobile/modules/common/profile/data/datasources/profile_data_source.dart';
import 'package:anestrack_mobile/modules/common/profile/data/datasources/profile_data_source_impl.dart';
import 'package:anestrack_mobile/modules/common/profile/data/repositories/profile_repository_impl.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/repositories/profile_repository.dart';
import 'package:anestrack_mobile/modules/common/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:anestrack_mobile/modules/common/profile/presentation/blocs/current_user_bloc.dart';
import 'package:anestrack_mobile/modules/student/complaints/data/datasources/complaint_data_source.dart';
import 'package:anestrack_mobile/modules/student/complaints/data/datasources/complaint_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/complaints/data/repositories/complaint_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/repositories/complaint_repository.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/usecases/create_complaint_usecase.dart';
import 'package:anestrack_mobile/modules/student/complaints/presentation/blocs/complaint_bloc.dart';
import 'package:anestrack_mobile/modules/common/devices/data/datasources/device_data_source.dart';
import 'package:anestrack_mobile/modules/common/devices/data/datasources/device_data_source_impl.dart';
import 'package:anestrack_mobile/modules/common/devices/data/repositories/device_repository_impl.dart';
import 'package:anestrack_mobile/modules/common/devices/domain/repositories/device_repository.dart';
import 'package:anestrack_mobile/modules/common/devices/domain/usecases/device_usecases.dart';
import 'package:anestrack_mobile/modules/common/notifications/data/datasources/notification_data_source.dart';
import 'package:anestrack_mobile/modules/common/notifications/data/datasources/notification_data_source_impl.dart';
import 'package:anestrack_mobile/modules/common/notifications/data/repositories/notification_repository_impl.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/repositories/notification_repository.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/usecases/notification_usecases.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/blocs/notifications_bloc.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/blocs/unread_count_bloc.dart';
import 'package:anestrack_mobile/modules/common/announcements/data/datasources/announcement_data_source.dart';
import 'package:anestrack_mobile/modules/common/announcements/data/datasources/announcement_data_source_impl.dart';
import 'package:anestrack_mobile/modules/common/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/repositories/announcement_repository.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/usecases/list_announcements_usecase.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/usecases/create_announcement_usecase.dart';
import 'package:anestrack_mobile/modules/common/announcements/presentation/blocs/announcements_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/blocs/create_announcement_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/ai_summary_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/ai_summary_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_assessment_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_assessment_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_attendance_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_attendance_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_evaluation_data_source.dart';
import 'package:anestrack_mobile/modules/student/education/data/datasources/lecture_evaluation_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/repositories/lecture_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/repositories/ai_summary_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/repositories/lecture_assessment_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/repositories/lecture_attendance_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/education/data/repositories/lecture_evaluation_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_repository.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/ai_summary_repository.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_assessment_repository.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_attendance_repository.dart';
import 'package:anestrack_mobile/modules/student/education/domain/repositories/lecture_evaluation_repository.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/list_lectures_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/get_lecture_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/create_lecture_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/generate_ai_summary_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/get_lecture_assessment_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/submit_answers_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/get_assessment_result_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/lecture_attendance_usecases.dart';
import 'package:anestrack_mobile/modules/student/education/domain/usecases/create_lecture_evaluation_usecase.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lectures_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_detail_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/ai_summary_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_assessment_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/assessment_result_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/assessment_review_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_attendance_bloc.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/blocs/lecture_evaluation_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/blocs/create_lecture_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_data_source.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_type_data_source.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_type_data_source_impl.dart';
import 'package:anestrack_mobile/modules/student/library/data/repositories/research_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/library/data/repositories/research_type_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_repository.dart';
import 'package:anestrack_mobile/modules/student/library/domain/repositories/research_type_repository.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/create_research_paper_usecase.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/get_research_paper_usecase.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/list_research_papers_usecase.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/list_research_types_usecase.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/list_research_paper_comments_usecase.dart';
import 'package:anestrack_mobile/modules/student/library/domain/usecases/create_research_paper_comment_usecase.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/publish_research_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_paper_detail_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_types_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_paper_comments_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/blocs/recent_activity_bloc.dart';

final sl = GetIt.instance;

class ServicesLocator {
  static ServicesLocator? _instance;
  ServicesLocator._();
  factory ServicesLocator() => _instance ??= ServicesLocator._();

  void init() {
    // BLE Live Co-Sign protocol — student advertises its co-sign code,
    // supervisor scans for it.
    sl.registerLazySingleton<StudentCodeBleAdvertiser>(
      () => StudentCodeBleAdvertiserImpl(),
    );
    sl.registerLazySingleton<SupervisorCodeBleScanner>(
      () => SupervisorCodeBleScannerImpl(),
    );

    // Device network connectivity — trigger only, never the authority on
    // whether a request actually succeeded (see ConnectivityService doc).
    sl.registerLazySingleton<ConnectivityService>(
      () => ConnectivityServiceImpl(),
    );

    // Auth Data Sources
    sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl());

    // Procedure Data Sources
    sl.registerLazySingleton<ProcedureDataSource>(
      () => ProcedureDataSourceImpl(),
    );
    sl.registerLazySingleton<HospitalProcedureTypeDataSource>(
      () => HospitalProcedureTypeDataSourceImpl(),
    );
    sl.registerLazySingleton<PendingProcedureLocalDataSource>(
      () => PendingProcedureLocalDataSourceImpl(),
    );
    sl.registerLazySingleton<ReferenceDataLocalDataSource>(
      () => ReferenceDataLocalDataSourceImpl(),
    );

    // Student Data Sources
    sl.registerLazySingleton<StudentDataSource>(() => StudentDataSourceImpl());

    // Student Dashboard Data Source
    sl.registerLazySingleton<StudentDashboardDataSource>(
      () => StudentDashboardDataSourceImpl(),
    );

    // Supervisor Dashboard Data Source
    sl.registerLazySingleton<SupervisorDashboardDataSource>(
      () => SupervisorDashboardDataSourceImpl(),
    );

    // Profile Data Source
    sl.registerLazySingleton<ProfileDataSource>(
      () => ProfileDataSourceImpl(),
    );

    // Complaint Data Source
    sl.registerLazySingleton<ComplaintDataSource>(
      () => ComplaintDataSourceImpl(),
    );

    // Notification Data Source
    sl.registerLazySingleton<NotificationDataSource>(
      () => NotificationDataSourceImpl(),
    );

    // Device (push registration) Data Source
    sl.registerLazySingleton<DeviceDataSource>(
      () => DeviceDataSourceImpl(),
    );

    // Announcement Data Source
    sl.registerLazySingleton<AnnouncementDataSource>(
      () => AnnouncementDataSourceImpl(),
    );

    // Education (lectures) Data Source
    sl.registerLazySingleton<LectureDataSource>(
      () => LectureDataSourceImpl(),
    );
    sl.registerLazySingleton<AiSummaryDataSource>(
      () => AiSummaryDataSourceImpl(),
    );
    sl.registerLazySingleton<LectureAssessmentDataSource>(
      () => LectureAssessmentDataSourceImpl(),
    );
    sl.registerLazySingleton<LectureAttendanceDataSource>(
      () => LectureAttendanceDataSourceImpl(),
    );
    sl.registerLazySingleton<LectureEvaluationDataSource>(
      () => LectureEvaluationDataSourceImpl(),
    );

    // Library (research) Data Source
    sl.registerLazySingleton<ResearchDataSource>(
      () => ResearchDataSourceImpl(),
    );
    sl.registerLazySingleton<ResearchTypeDataSource>(
      () => ResearchTypeDataSourceImpl(),
    );

    // Repositories
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthDataSource>()),
    );
    sl.registerLazySingleton<ProcedureRepository>(
      () => ProcedureRepositoryImpl(sl<ProcedureDataSource>()),
    );
    sl.registerLazySingleton<HospitalRepository>(
      () => HospitalRepositoryImpl(
        sl<HospitalProcedureTypeDataSource>(),
        sl<ReferenceDataLocalDataSource>(),
      ),
    );
    sl.registerLazySingleton<ProcedureTypeRepository>(
      () => ProcedureTypeRepositoryImpl(
        sl<HospitalProcedureTypeDataSource>(),
        sl<ReferenceDataLocalDataSource>(),
      ),
    );
    sl.registerLazySingleton<SupervisorRepository>(
      () => SupervisorRepositoryImpl(
        sl<HospitalProcedureTypeDataSource>(),
        sl<ReferenceDataLocalDataSource>(),
      ),
    );
    sl.registerLazySingleton<PendingProcedureRepository>(
      () => PendingProcedureRepositoryImpl(sl<PendingProcedureLocalDataSource>()),
    );
    sl.registerLazySingleton<StudentRepository>(
      () => StudentRepositoryImpl(sl<StudentDataSource>()),
    );
    sl.registerLazySingleton<SupervisorDashboardRepository>(
      () => SupervisorDashboardRepositoryImpl(sl<SupervisorDashboardDataSource>()),
    );
    sl.registerLazySingleton<StudentDashboardRepository>(
      () => StudentDashboardRepositoryImpl(sl<StudentDashboardDataSource>()),
    );
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileDataSource>()),
    );
    sl.registerLazySingleton<ComplaintRepository>(
      () => ComplaintRepositoryImpl(sl<ComplaintDataSource>()),
    );
    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(sl<NotificationDataSource>()),
    );
    sl.registerLazySingleton<DeviceRepository>(
      () => DeviceRepositoryImpl(sl<DeviceDataSource>()),
    );
    sl.registerLazySingleton<AnnouncementRepository>(
      () => AnnouncementRepositoryImpl(sl<AnnouncementDataSource>()),
    );
    sl.registerLazySingleton<LectureRepository>(
      () => LectureRepositoryImpl(sl<LectureDataSource>()),
    );
    sl.registerLazySingleton<AiSummaryRepository>(
      () => AiSummaryRepositoryImpl(sl<AiSummaryDataSource>()),
    );
    sl.registerLazySingleton<LectureAssessmentRepository>(
      () => LectureAssessmentRepositoryImpl(sl<LectureAssessmentDataSource>()),
    );
    sl.registerLazySingleton<LectureAttendanceRepository>(
      () => LectureAttendanceRepositoryImpl(sl<LectureAttendanceDataSource>()),
    );
    sl.registerLazySingleton<LectureEvaluationRepository>(
      () => LectureEvaluationRepositoryImpl(sl<LectureEvaluationDataSource>()),
    );
    sl.registerLazySingleton<ResearchRepository>(
      () => ResearchRepositoryImpl(sl<ResearchDataSource>()),
    );
    sl.registerLazySingleton<ResearchTypeRepository>(
      () => ResearchTypeRepositoryImpl(sl<ResearchTypeDataSource>()),
    );

    // Use Cases
    sl.registerLazySingleton<ListProceduresUseCase>(
      () => ListProceduresUseCase(sl<ProcedureRepository>()),
    );
    sl.registerLazySingleton<CreateProcedureUseCase>(
      () => CreateProcedureUseCase(sl<ProcedureRepository>()),
    );
    sl.registerLazySingleton<EnqueueOfflineProcedureUseCase>(
      () => EnqueueOfflineProcedureUseCase(sl<PendingProcedureRepository>()),
    );
    sl.registerLazySingleton<ListPendingProceduresUseCase>(
      () => ListPendingProceduresUseCase(sl<PendingProcedureRepository>()),
    );
    sl.registerLazySingleton<SyncPendingProceduresUseCase>(
      () => SyncPendingProceduresUseCase(
        sl<PendingProcedureRepository>(),
        sl<ProcedureRepository>(),
        sl<ConnectivityService>(),
      ),
    );
    sl.registerLazySingleton<CoSignProcedureUseCase>(
      () => CoSignProcedureUseCase(sl<ProcedureRepository>()),
    );
    sl.registerLazySingleton<GetCoSignContextUseCase>(
      () => GetCoSignContextUseCase(sl<ProcedureRepository>()),
    );
    sl.registerLazySingleton<ConfirmProcedureUseCase>(
      () => ConfirmProcedureUseCase(sl<ProcedureRepository>()),
    );
    sl.registerLazySingleton<CreateEvaluationUseCase>(
      () => CreateEvaluationUseCase(sl<ProcedureRepository>()),
    );
    sl.registerLazySingleton<ListPendingForSupervisorUseCase>(
      () => ListPendingForSupervisorUseCase(sl<ProcedureRepository>()),
    );
    sl.registerLazySingleton<ListHospitalsUseCase>(
      () => ListHospitalsUseCase(sl<HospitalRepository>()),
    );
    sl.registerLazySingleton<ListProcedureTypesUseCase>(
      () => ListProcedureTypesUseCase(sl<ProcedureTypeRepository>()),
    );
    sl.registerLazySingleton<ListSupervisorsUseCase>(
      () => ListSupervisorsUseCase(sl<SupervisorRepository>()),
    );
    sl.registerLazySingleton<ListStudentsUseCase>(
      () => ListStudentsUseCase(sl<StudentRepository>()),
    );
    sl.registerLazySingleton<GetSupervisorDashboardUseCase>(
      () => GetSupervisorDashboardUseCase(sl<SupervisorDashboardRepository>()),
    );
    sl.registerLazySingleton<GetStudentDashboardUseCase>(
      () => GetStudentDashboardUseCase(sl<StudentDashboardRepository>()),
    );
    sl.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(sl<ProfileRepository>()),
    );
    sl.registerLazySingleton<CreateComplaintUseCase>(
      () => CreateComplaintUseCase(sl<ComplaintRepository>()),
    );
    sl.registerLazySingleton<ListNotificationsUseCase>(
      () => ListNotificationsUseCase(sl<NotificationRepository>()),
    );
    sl.registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(sl<NotificationRepository>()),
    );
    sl.registerLazySingleton<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(sl<NotificationRepository>()),
    );
    sl.registerLazySingleton<MarkAllNotificationsReadUseCase>(
      () => MarkAllNotificationsReadUseCase(sl<NotificationRepository>()),
    );
    sl.registerLazySingleton<RegisterDeviceUseCase>(
      () => RegisterDeviceUseCase(sl<DeviceRepository>()),
    );
    sl.registerLazySingleton<UnregisterDeviceUseCase>(
      () => UnregisterDeviceUseCase(sl<DeviceRepository>()),
    );
    sl.registerLazySingleton<ListAnnouncementsUseCase>(
      () => ListAnnouncementsUseCase(sl<AnnouncementRepository>()),
    );
    sl.registerLazySingleton<CreateAnnouncementUseCase>(
      () => CreateAnnouncementUseCase(sl<AnnouncementRepository>()),
    );
    sl.registerLazySingleton<ListLecturesUseCase>(
      () => ListLecturesUseCase(sl<LectureRepository>()),
    );
    sl.registerLazySingleton<GetLectureUseCase>(
      () => GetLectureUseCase(sl<LectureRepository>()),
    );
    sl.registerLazySingleton<CreateLectureUseCase>(
      () => CreateLectureUseCase(sl<LectureRepository>()),
    );
    sl.registerLazySingleton<GenerateAiSummaryUseCase>(
      () => GenerateAiSummaryUseCase(sl<AiSummaryRepository>()),
    );
    sl.registerLazySingleton<GetLectureAssessmentUseCase>(
      () => GetLectureAssessmentUseCase(sl<LectureAssessmentRepository>()),
    );
    sl.registerLazySingleton<SubmitAnswersUseCase>(
      () => SubmitAnswersUseCase(sl<LectureAssessmentRepository>()),
    );
    sl.registerLazySingleton<GetAssessmentResultUseCase>(
      () => GetAssessmentResultUseCase(sl<LectureAssessmentRepository>()),
    );
    sl.registerLazySingleton<EnsureAttendanceUseCase>(
      () => EnsureAttendanceUseCase(sl<LectureAttendanceRepository>()),
    );
    sl.registerLazySingleton<MarkAttendanceCompletedUseCase>(
      () => MarkAttendanceCompletedUseCase(sl<LectureAttendanceRepository>()),
    );
    sl.registerLazySingleton<CreateLectureEvaluationUseCase>(
      () => CreateLectureEvaluationUseCase(sl<LectureEvaluationRepository>()),
    );
    sl.registerLazySingleton<ListResearchPapersUseCase>(
      () => ListResearchPapersUseCase(sl<ResearchRepository>()),
    );
    sl.registerLazySingleton<GetResearchPaperUseCase>(
      () => GetResearchPaperUseCase(sl<ResearchRepository>()),
    );
    sl.registerLazySingleton<CreateResearchPaperUseCase>(
      () => CreateResearchPaperUseCase(sl<ResearchRepository>()),
    );
    sl.registerLazySingleton<ListResearchPaperCommentsUseCase>(
      () => ListResearchPaperCommentsUseCase(sl<ResearchRepository>()),
    );
    sl.registerLazySingleton<CreateResearchPaperCommentUseCase>(
      () => CreateResearchPaperCommentUseCase(sl<ResearchRepository>()),
    );
    sl.registerLazySingleton<ListResearchTypesUseCase>(
      () => ListResearchTypesUseCase(sl<ResearchTypeRepository>()),
    );

    // Blocs
    sl.registerFactory<ThemeBloc>(() => ThemeBloc());
    sl.registerFactory<LoginBloc>(() => LoginBloc(sl<AuthRepository>()));
    sl.registerFactory<LogoutBloc>(
      () => LogoutBloc(sl<AuthRepository>(), sl<SupervisorCodeBleScanner>()),
    );
    // Singleton: the student procedures list stays alive inside the home
    // IndexedStack, so other flows (e.g. create-procedure) can reach the
    // same instance via `sl<ProceduresBloc>()` to trigger a refresh.
    sl.registerLazySingleton<ProceduresBloc>(
      () => ProceduresBloc(sl<ListProceduresUseCase>()),
    );
    sl.registerFactory<CreateProcedureBloc>(
      () => CreateProcedureBloc(
        sl<CreateProcedureUseCase>(),
        sl<EnqueueOfflineProcedureUseCase>(),
      ),
    );
    // Singleton: student_procedures_screen.dart, student_home_screen.dart
    // and ProcedureSyncService all need to reach the same pending-queue
    // instance, same reasoning as ProceduresBloc above.
    sl.registerLazySingleton<PendingProceduresBloc>(
      () => PendingProceduresBloc(sl<ListPendingProceduresUseCase>()),
    );
    sl.registerFactory<HospitalsBloc>(
      () => HospitalsBloc(sl<ListHospitalsUseCase>()),
    );
    sl.registerFactory<ProcedureTypesBloc>(
      () => ProcedureTypesBloc(sl<ListProcedureTypesUseCase>()),
    );
    sl.registerFactory<SupervisorsBloc>(
      () => SupervisorsBloc(sl<ListSupervisorsUseCase>()),
    );
    sl.registerFactory<CoSignBleBloc>(
      () => CoSignBleBloc(sl<StudentCodeBleAdvertiser>()),
    );

    // Supervisor review / co-sign blocs
    sl.registerFactory<PendingBloc>(
      () => PendingBloc(sl<ListPendingForSupervisorUseCase>()),
    );
    sl.registerFactory<CoSignContextBloc>(
      () => CoSignContextBloc(sl<GetCoSignContextUseCase>()),
    );
    sl.registerFactory<CoSignActionBloc>(
      () => CoSignActionBloc(sl<CoSignProcedureUseCase>()),
    );
    sl.registerFactory<ConfirmActionBloc>(
      () => ConfirmActionBloc(sl<ConfirmProcedureUseCase>()),
    );
    sl.registerFactory<EvaluationActionBloc>(
      () => EvaluationActionBloc(sl<CreateEvaluationUseCase>()),
    );
    sl.registerFactory<LiveCoSignBloc>(
      () => LiveCoSignBloc(sl<SupervisorCodeBleScanner>()),
    );

    // Supervisor students bloc
    sl.registerFactory<StudentsBloc>(
      () => StudentsBloc(sl<ListStudentsUseCase>()),
    );

    // Supervisor home dashboard bloc
    sl.registerFactory<DashboardBloc>(
      () => DashboardBloc(sl<GetSupervisorDashboardUseCase>()),
    );

    // Student home dashboard bloc
    sl.registerFactory<StudentDashboardBloc>(
      () => StudentDashboardBloc(sl<GetStudentDashboardUseCase>()),
    );

    // Profile
    sl.registerFactory<CurrentUserBloc>(
      () => CurrentUserBloc(sl<GetCurrentUserUseCase>()),
    );

    // Complaint
    sl.registerFactory<ComplaintBloc>(
      () => ComplaintBloc(sl<CreateComplaintUseCase>()),
    );

    // Notifications
    sl.registerFactory<NotificationsBloc>(
      () => NotificationsBloc(
        sl<ListNotificationsUseCase>(),
        sl<MarkNotificationReadUseCase>(),
        sl<MarkAllNotificationsReadUseCase>(),
      ),
    );
    // Singleton: the home-screen bell badge and the notifications screen's
    // mark-as-read actions need to reach the same instance to stay in sync.
    sl.registerLazySingleton<UnreadCountBloc>(
      () => UnreadCountBloc(sl<GetUnreadCountUseCase>()),
    );

    // Announcements
    sl.registerFactory<CreateAnnouncementBloc>(
      () => CreateAnnouncementBloc(sl<CreateAnnouncementUseCase>()),
    );
    sl.registerFactory<AnnouncementsBloc>(
      () => AnnouncementsBloc(sl<ListAnnouncementsUseCase>()),
    );

    // Education (lectures)
    sl.registerFactory<LecturesBloc>(
      () => LecturesBloc(sl<ListLecturesUseCase>()),
    );
    sl.registerFactory<CreateLectureBloc>(
      () => CreateLectureBloc(sl<CreateLectureUseCase>()),
    );
    sl.registerFactory<LectureDetailBloc>(
      () => LectureDetailBloc(sl<GetLectureUseCase>()),
    );
    sl.registerFactory<AiSummaryBloc>(
      () => AiSummaryBloc(sl<GenerateAiSummaryUseCase>()),
    );
    sl.registerFactory<LectureAssessmentBloc>(
      () => LectureAssessmentBloc(sl<GetLectureAssessmentUseCase>()),
    );
    sl.registerFactory<AssessmentResultBloc>(
      () => AssessmentResultBloc(sl<SubmitAnswersUseCase>()),
    );
    sl.registerFactory<AssessmentReviewBloc>(
      () => AssessmentReviewBloc(sl<GetAssessmentResultUseCase>()),
    );
    sl.registerFactory<LectureAttendanceBloc>(
      () => LectureAttendanceBloc(
        sl<EnsureAttendanceUseCase>(),
        sl<MarkAttendanceCompletedUseCase>(),
      ),
    );
    sl.registerFactory<LectureEvaluationBloc>(
      () => LectureEvaluationBloc(sl<CreateLectureEvaluationUseCase>()),
    );

    // Library (research)
    sl.registerFactory<ResearchBloc>(
      () => ResearchBloc(sl<ListResearchPapersUseCase>()),
    );
    sl.registerFactory<ResearchPaperDetailBloc>(
      () => ResearchPaperDetailBloc(sl<GetResearchPaperUseCase>()),
    );
    sl.registerFactory<ResearchTypesBloc>(
      () => ResearchTypesBloc(sl<ListResearchTypesUseCase>()),
    );
    sl.registerFactory<PublishResearchBloc>(
      () => PublishResearchBloc(sl<CreateResearchPaperUseCase>()),
    );
    sl.registerFactory<ResearchPaperCommentsBloc>(
      () => ResearchPaperCommentsBloc(
        sl<ListResearchPaperCommentsUseCase>(),
        sl<CreateResearchPaperCommentUseCase>(),
      ),
    );
    sl.registerFactory<RecentActivityBloc>(
      () => RecentActivityBloc(
        sl<ListLecturesUseCase>(),
        sl<ListResearchPapersUseCase>(),
        sl<ListAnnouncementsUseCase>(),
      ),
    );

    // Offline procedure sync — background trigger that drains the pending
    // queue once connectivity returns. Registered last since it depends on
    // ConnectivityService and SyncPendingProceduresUseCase above.
    sl.registerLazySingleton<ProcedureSyncService>(
      () => ProcedureSyncServiceImpl(
        sl<ConnectivityService>(),
        sl<SyncPendingProceduresUseCase>(),
      ),
    );
  }
}
