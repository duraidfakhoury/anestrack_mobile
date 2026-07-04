import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import '../models/hospital_model.dart';
import '../models/procedure_type_model.dart';
import '../models/supervisor_model.dart';

abstract class HospitalProcedureTypeDataSource {
  Future<List<HospitalModel>> listHospitals();
  Future<List<ProcedureTypeModel>> listProcedureTypes();
  Future<List<SupervisorModel>> listSupervisors();
}

class HospitalProcedureTypeDataSourceImpl
    implements HospitalProcedureTypeDataSource {
  final Logger _logger = Logger();

  HospitalProcedureTypeDataSourceImpl();

  @override
  Future<List<HospitalModel>> listHospitals() async {
    try {
      _logger.i("Fetching hospitals...");

      final response = await NetworkHelper().get(ApisUrls().listHospitals);

      _logger.i("Hospitals API Response Status: ${response.statusCode}");

      List<dynamic>? rawList;

      // Case 1: The response is directly a JSON List (Array)
      if (response.data is List) {
        rawList = response.data as List;
      }
      // Case 2: The response is wrapped inside a JSON Map object {"result": [...]}
      else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['result'] is List) {
          rawList = data['result'] as List;
        }
      }

      if (rawList != null) {
        final hospitals = rawList
            .map((item) => HospitalModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _logger.i("Successfully fetched ${hospitals.length} hospitals");
        return hospitals;
      }

      _logger.w("Unexpected response format: ${response.data}");
      return [];
    } catch (e) {
      _logger.e("Failed to fetch hospitals: $e");
      rethrow;
    }
  }

  @override
  Future<List<ProcedureTypeModel>> listProcedureTypes() async {
    try {
      _logger.i("Fetching procedure types...");

      final response = await NetworkHelper().get(ApisUrls().listProcedureTypes);

      _logger.i("Procedure Types API Response Status: ${response.statusCode}");

      List<dynamic>? rawList;

      // Case 1: The response is directly a JSON List (Array)
      if (response.data is List) {
        rawList = response.data as List;
      }
      // Case 2: The response is wrapped inside a JSON Map object {"result": [...]}
      else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['result'] is List) {
          rawList = data['result'] as List;
        }
      }

      if (rawList != null) {
        final procedureTypes = rawList
            .map(
              (item) =>
                  ProcedureTypeModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        _logger.i(
          "Successfully fetched ${procedureTypes.length} procedure types",
        );
        return procedureTypes;
      }

      _logger.w("Unexpected response format: ${response.data}");
      return [];
    } catch (e) {
      _logger.e("Failed to fetch procedure types: $e");
      rethrow;
    }
  }

  @override
  Future<List<SupervisorModel>> listSupervisors() async {
    try {
      _logger.i("Fetching supervisors...");

      final response = await NetworkHelper().get(ApisUrls().listSupervisors);

      _logger.i("Supervisors API Response Status: ${response.statusCode}");

      List<dynamic>? rawList;
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['result'] is List) {
          rawList = data['result'] as List;
        }
      }

      if (rawList != null) {
        final supervisors = rawList
            .whereType<Map>()
            .map(
              (item) =>
                  SupervisorModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
        _logger.i("Successfully fetched ${supervisors.length} supervisors");
        return supervisors;
      }

      _logger.w("Unexpected response format: ${response.data}");
      return [];
    } catch (e) {
      _logger.e("Failed to fetch supervisors: $e");
      rethrow;
    }
  }
}
