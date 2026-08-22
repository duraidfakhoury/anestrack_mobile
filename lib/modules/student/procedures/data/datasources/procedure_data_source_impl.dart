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
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/evaluation_parameters.dart';

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

  /// `createProcedure`/`coSignProcedure`/`confirmProcedure` all return a flat
  /// procedure object for a single-type request, but a session envelope —
  /// `{sessionId, sessionSize, procedures: [...]}`, no top-level `status`/`id`
  /// — once more than one procedure type is involved (see
  /// `integration-mobile.md` §5). Parsing the envelope itself as a
  /// `ProcedureModel` silently defaults every field (`status` becomes
  /// `Pending`, `id` becomes `''`), which is exactly backwards from what
  /// happened. Pick the row matching [preferredId] (the row the caller acted
  /// on) so status/decision reads correctly; any row is representative since
  /// deciding one without an explicit `ids` subset decides the whole session.
  ProcedureModel _extractProcedure(
    Map<String, dynamic> body, {
    String? preferredId,
  }) {
    final rows = body['procedures'];
    if (rows is List && rows.isNotEmpty) {
      final maps = rows
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      Map<String, dynamic>? match;
      if (preferredId != null) {
        for (final m in maps) {
          if ((m['objectId'] ?? m['id']) == preferredId) {
            match = m;
            break;
          }
        }
      }
      final row = match ?? maps.first;
      return ProcedureModel.fromJson({
        ...row,
        // Some backend builds additionally surface the decision's outcome at
        // the envelope's top level rather than only per-row — prefer it when
        // present so a future shape change can't reintroduce the "shows
        // Reject for a Confirm" bug this was written to fix.
        if (body['status'] != null) 'status': body['status'],
      });
    }
    return ProcedureModel.fromJson(body);
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
        final rows = map['procedures'];

        // Multi-type session envelope: `{sessionId, sessionSize, coSignCode,
        // procedures: [...]}`. Each row is sparse (just objectId/procedureType
        // pointer/sessionId) — the shared fields (patientName, procedureDate)
        // live on the request, not the response, so backfill them here.
        final ProcedureModel procedure;
        if (rows is List && rows.isNotEmpty) {
          final first = Map<String, dynamic>.from(rows.first as Map);
          procedure = ProcedureModel.fromJson({
            ...first,
            'patientName': parameters.patientName,
            'procedureDate': parameters.procedureDate,
            'sessionId': first['sessionId'] ?? map['sessionId'],
            'sessionSize': first['sessionSize'] ?? map['sessionSize'],
          });
        } else {
          procedure = ProcedureModel.fromJson(map);
        }

        final result = CreateProcedureResult(
          procedure: procedure,
          coSignCode: map['coSignCode'] as String?,
        );
        _logger.i(
          "Procedure created (liveCoSign: ${result.requiresLiveCoSign}, "
          "sessionSize: ${procedure.sessionSize ?? 1})",
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
        return _extractProcedure(
          Map<String, dynamic>.from(body),
          preferredId: parameters.id,
        );
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
        return _extractProcedure(
          Map<String, dynamic>.from(body),
          preferredId: parameters.id,
        );
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

  @override
  Future<bool> createEvaluation(EvaluationParameters parameters) async {
    try {
      _logger.i("Creating evaluation: ${parameters.toJson()}");
      await NetworkHelper().post(
        ApisUrls().createEvaluation,
        data: parameters.toJson(),
      );
      return true;
    } catch (e) {
      _logger.e("Failed to create evaluation: $e");
      rethrow;
    }
  }
}
