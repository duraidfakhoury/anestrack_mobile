import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/hospital.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/usecases/list_hospitals_usecase.dart';
import 'package:logger/logger.dart';

part 'hospitals_event.dart';
part 'hospitals_state.dart';

class HospitalsBloc extends Bloc<HospitalsEvent, HospitalsState> {
  final ListHospitalsUseCase listHospitalsUseCase;

  HospitalsBloc(this.listHospitalsUseCase)
    : super(const BaseState<List<Hospital>>()) {
    on<FetchHospitalsEvent>(_onFetchHospitals);
  }

  Future<void> _onFetchHospitals(
    FetchHospitalsEvent event,
    Emitter<HospitalsState> emit,
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
