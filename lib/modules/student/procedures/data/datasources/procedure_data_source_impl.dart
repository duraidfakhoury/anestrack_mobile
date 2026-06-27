import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/procedure_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';

class ProcedureDataSourceImpl extends ProcedureDataSource {
  final Logger _logger = Logger();

  @override
  Future<List<ProcedureModel>> listProcedures(
    ListProceduresParameters parameters,
  ) async {
    try {
      _logger.i("Fetching procedures with parameters: ${parameters.toJson()}");

      final response = await NetworkHelper().get(
        ApisUrls().listProcedures,
        data: parameters.toJson(),
      );

      _logger.i("Procedures API Response Status: ${response.statusCode}");

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final result = data['result'];

        if (result is List) {
          final procedures = (result as List)
              .map(
                (item) => ProcedureModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          _logger.i("Successfully fetched ${procedures.length} procedures");
          return procedures;
        }
      }

      _logger.w("Unexpected response format: ${response.data}");
      return [];
    } catch (e) {
      _logger.e("Failed to fetch procedures: $e");
      rethrow;
    }
  }

  @override
  Future<bool> createProcedure(
    CreateProcedureParameters parameters,
  ) async {
    try {
      _logger.i("Creating procedure with parameters: ${parameters.toJson()}");

      final response = await NetworkHelper().post(
        ApisUrls().createProcedure,
        data: parameters.toJson(),
      );

      _logger.i("Create Procedure API Response Status: ${response.statusCode}");
      _logger.i("Create Procedure API Response Data: ${response.data}");

      if (response.statusCode == 200) {
        _logger.i("Procedure created successfully");
        return true;
      }

      _logger.w("Unexpected response status: ${response.statusCode}");
      return false;
    } catch (e) {
      _logger.e("Failed to create procedure: $e");
      rethrow;
    }
  }
}
