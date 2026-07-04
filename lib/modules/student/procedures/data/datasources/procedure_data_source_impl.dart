import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/datasources/procedure_data_source.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/data/models/co_sign_context_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/list_procedures_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/co_sign_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/confirm_procedure_parameters.dart';

class ProcedureDataSourceImpl extends ProcedureDataSource {
  final Logger _logger = Logger();

  /// `/api/functions/*` strips the Parse `result` wrapper, so the body is the
  /// raw return value. We still tolerate a `{result: ...}` envelope defensively.
  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  List<ProcedureModel> _toProcedureList(dynamic body) {
    final unwrapped = _unwrap(body);
    if (unwrapped is List) {
      return unwrapped
          .whereType<Map>()
          .map((e) => ProcedureModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    _logger.w("Unexpected list response format: $body");
    return [];
  }

  @override
  Future<List<ProcedureModel>> listProcedures(
    ListProceduresParameters parameters,
  ) async {
    try {
      _logger.i("Fetching procedures: ${parameters.toJson()}");
      final response = await NetworkHelper().get(
        ApisUrls().listProcedures,
        data: parameters.toJson(),
      );
      final procedures = _toProcedureList(response.data);
      _logger.i("Fetched ${procedures.length} procedures");
      return procedures;
    } catch (e) {
      _logger.e("Failed to fetch procedures: $e");
      rethrow;
    }
  }

  @override
  Future<CreateProcedureResult> createProcedure(
    CreateProcedureParameters parameters,
  ) async {
    try {
      _logger.i("Creating procedure: ${parameters.toJson()}");
      final response = await NetworkHelper().post(
        ApisUrls().createProcedure,
        data: parameters.toJson(),
      );

      final body = _unwrap(response.data);
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        final result = CreateProcedureResult(
          procedure: ProcedureModel.fromJson(map),
          coSignCode: map['coSignCode'] as String?,
        );
        _logger.i(
          "Procedure created (liveCoSign: ${result.requiresLiveCoSign})",
        );
        return result;
      }
      throw Exception("Unexpected createProcedure response: ${response.data}");
    } catch (e) {
      _logger.e("Failed to create procedure: $e");
      rethrow;
    }
  }

  @override
  Future<ProcedureModel> coSignProcedure(CoSignParameters parameters) async {
    try {
      _logger.i("Co-signing procedure: ${parameters.toJson()}");
      final response = await NetworkHelper().post(
        ApisUrls().coSignProcedure,
        data: parameters.toJson(),
      );
      final body = _unwrap(response.data);
      if (body is Map) {
        return ProcedureModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception("Unexpected coSignProcedure response: ${response.data}");
    } catch (e) {
      _logger.e("Failed to co-sign procedure: $e");
      rethrow;
    }
  }

  @override
  Future<CoSignContextModel> getCoSignContext(String coSignCode) async {
    try {
      _logger.i("Fetching co-sign context");
      final response = await NetworkHelper().get(
        ApisUrls().getCoSignContext,
        data: {'coSignCode': coSignCode},
      );
      final body = _unwrap(response.data);
      if (body is Map) {
        return CoSignContextModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception("Unexpected getCoSignContext response: ${response.data}");
    } catch (e) {
      _logger.e("Failed to fetch co-sign context: $e");
      rethrow;
    }
  }

  @override
  Future<ProcedureModel> confirmProcedure(
    ConfirmProcedureParameters parameters,
  ) async {
    try {
      _logger.i("Confirming procedure: ${parameters.toJson()}");
      final response = await NetworkHelper().put(
        ApisUrls().confirmProcedure,
        data: parameters.toJson(),
      );
      final body = _unwrap(response.data);
      if (body is Map) {
        return ProcedureModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception("Unexpected confirmProcedure response: ${response.data}");
    } catch (e) {
      _logger.e("Failed to confirm procedure: $e");
      rethrow;
    }
  }

  @override
  Future<List<ProcedureModel>> listPendingForSupervisor() async {
    try {
      _logger.i("Fetching pending procedures for supervisor");
      final response = await NetworkHelper().get(
        ApisUrls().listPendingForSupervisor,
      );
      final procedures = _toProcedureList(response.data);
      _logger.i("Fetched ${procedures.length} pending procedures");
      return procedures;
    } catch (e) {
      _logger.e("Failed to fetch pending procedures: $e");
      rethrow;
    }
  }
}
