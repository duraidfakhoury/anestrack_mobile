import 'package:anestrack_mobile/core/services/ble/supervisor_code_ble_scanner.dart';
import 'package:anestrack_mobile/core/services/ble/student_code_ble_advertiser.dart';
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
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/procedure_repository.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/repositories/procedure_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/repositories/hospital_procedure_type_repository_impl.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/repositories/hospital_procedure_type_repository.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_procedures_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/create_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/co_sign_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/get_co_sign_context_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/confirm_procedure_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_pending_for_supervisor_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_hospitals_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_procedure_types_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_supervisors_usecase.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/co_sign_ble_bloc/co_sign_ble_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/hospitals_bloc/hospitals_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedure_types_bloc/procedure_types_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/supervisors_bloc/supervisors_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/pending_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_context_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/confirm_action_bloc.dart';
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
import 'package:anestrack_mobile/modules/common/announcements/presentation/blocs/announcements_bloc.dart';

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

    // Auth Data Sources
    sl.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl());

    // Procedure Data Sources
    sl.registerLazySingleton<ProcedureDataSource>(
      () => ProcedureDataSourceImpl(),
    );
    sl.registerLazySingleton<HospitalProcedureTypeDataSource>(
      () => HospitalProcedureTypeDataSourceImpl(),
    );

    // Student Data Sources
    sl.registerLazySingleton<StudentDataSource>(() => StudentDataSourceImpl());

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

    // Announcement Data Source
    sl.registerLazySingleton<AnnouncementDataSource>(
      () => AnnouncementDataSourceImpl(),
    );

    // Repositories
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthDataSource>()),
    );
    sl.registerLazySingleton<ProcedureRepository>(
      () => ProcedureRepositoryImpl(sl<ProcedureDataSource>()),
    );
    sl.registerLazySingleton<HospitalRepository>(
      () => HospitalRepositoryImpl(sl<HospitalProcedureTypeDataSource>()),
    );
    sl.registerLazySingleton<ProcedureTypeRepository>(
      () => ProcedureTypeRepositoryImpl(sl<HospitalProcedureTypeDataSource>()),
    );
    sl.registerLazySingleton<SupervisorRepository>(
      () => SupervisorRepositoryImpl(sl<HospitalProcedureTypeDataSource>()),
    );
    sl.registerLazySingleton<StudentRepository>(
      () => StudentRepositoryImpl(sl<StudentDataSource>()),
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
    sl.registerLazySingleton<AnnouncementRepository>(
      () => AnnouncementRepositoryImpl(sl<AnnouncementDataSource>()),
    );

    // Use Cases
    sl.registerLazySingleton<ListProceduresUseCase>(
      () => ListProceduresUseCase(sl<ProcedureRepository>()),
    );
    sl.registerLazySingleton<CreateProcedureUseCase>(
      () => CreateProcedureUseCase(sl<ProcedureRepository>()),
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
    sl.registerLazySingleton<ListAnnouncementsUseCase>(
      () => ListAnnouncementsUseCase(sl<AnnouncementRepository>()),
    );

    // Blocs
    sl.registerFactory<ThemeBloc>(() => ThemeBloc());
    sl.registerFactory<LoginBloc>(() => LoginBloc(sl<AuthRepository>()));
    sl.registerFactory<LogoutBloc>(
      () => LogoutBloc(sl<AuthRepository>(), sl<SupervisorCodeBleScanner>()),
    );
    sl.registerFactory<ProceduresBloc>(
      () => ProceduresBloc(sl<ListProceduresUseCase>()),
    );
    sl.registerFactory<CreateProcedureBloc>(
      () => CreateProcedureBloc(sl<CreateProcedureUseCase>()),
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
    sl.registerFactory<LiveCoSignBloc>(
      () => LiveCoSignBloc(sl<SupervisorCodeBleScanner>()),
    );

    // Supervisor students bloc
    sl.registerFactory<StudentsBloc>(
      () => StudentsBloc(sl<ListStudentsUseCase>()),
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
    sl.registerFactory<UnreadCountBloc>(
      () => UnreadCountBloc(sl<GetUnreadCountUseCase>()),
    );

    // Announcements
    sl.registerFactory<AnnouncementsBloc>(
      () => AnnouncementsBloc(sl<ListAnnouncementsUseCase>()),
    );
  }
}
