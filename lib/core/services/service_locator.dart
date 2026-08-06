import 'package:anestrack_mobile/core/services/google_auth_service.dart';
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
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/hospitals_bloc/hospitals_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedure_types_bloc/procedure_types_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/supervisors_bloc/supervisors_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/pending_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_context_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/co_sign_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/reviews/presentation/blocs/confirm_action_bloc.dart';
import 'package:anestrack_mobile/modules/supervisor/students/data/datasources/student_data_source.dart';
import 'package:anestrack_mobile/modules/supervisor/students/data/datasources/student_data_source_impl.dart';
import 'package:anestrack_mobile/modules/supervisor/students/data/repositories/student_repository_impl.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/repositories/student_repository.dart';
import 'package:anestrack_mobile/modules/supervisor/students/domain/usecases/list_students_usecase.dart';
import 'package:anestrack_mobile/modules/supervisor/students/presentation/blocs/students_bloc/students_bloc.dart';

final sl = GetIt.instance;

class ServicesLocator {
  static ServicesLocator? _instance;
  ServicesLocator._();
  factory ServicesLocator() => _instance ??= ServicesLocator._();

  void init() {
    sl.registerLazySingleton<GoogleAuthService>(() => GoogleAuthService());

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
    sl.registerLazySingleton<StudentDataSource>(
      () => StudentDataSourceImpl(),
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

    // Blocs
    sl.registerFactory<ThemeBloc>(() => ThemeBloc());
    sl.registerFactory<LoginBloc>(() => LoginBloc(sl<AuthRepository>()));
    sl.registerFactory<LogoutBloc>(() => LogoutBloc(sl<AuthRepository>()));
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

    // Supervisor students bloc
    sl.registerFactory<StudentsBloc>(
      () => StudentsBloc(sl<ListStudentsUseCase>()),
    );
  }
}
