import 'package:anestrack_mobile/modules/student/procedures/data/models/procedure_model.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/co_sign_context.dart';

class CoSignContextModel extends CoSignContext {
  const CoSignContextModel({
    super.procedureId,
    super.studentName,
    super.procedureType,
    super.expiresAt,
  });

  factory CoSignContextModel.fromJson(Map<String, dynamic> json) {
    return CoSignContextModel(
      procedureId: json['procedureId'] as String?,
      studentName: json['studentName'] as String?,
      procedureType: json['procedureType'] as String?,
      expiresAt: ProcedureModel.parseDate(json['expiresAt']),
    );
  }
}
