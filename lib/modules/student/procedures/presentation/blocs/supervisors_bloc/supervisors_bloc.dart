import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_hospitals_usecase.dart';
import 'package:logger/logger.dart';

part 'supervisors_event.dart';
part 'supervisors_state.dart';

class SupervisorsBloc extends Bloc<SupervisorsEvent, SupervisorsState> {
  final ListHospitalsUseCase listHospitalsUseCase;

  SupervisorsBloc(this.listHospitalsUseCase)
    : super(const BaseState<List<Hospital>>()) {
    on<FetchHospitalsEvent>(_onFetchHospitals);
  }

  Future<void> _onFetchHospitals(
    FetchHospitalsEvent event,
    Emitter<SupervisorsState> emit,
  ) async {
    emit(state.loading());
      final result = await listHospitalsUseCase();
      result.fold(
        (failure) {
          Logger().e('Failed to fetch hospitals: ${ failure.message}');
          emit(state.error(failure));
        },
        (hospitals) {
          Logger().i('Successfully fetched ${hospitals.length} hospitals');
          emit(state.successNotNull(hospitals));
        },
      );
  }
}
