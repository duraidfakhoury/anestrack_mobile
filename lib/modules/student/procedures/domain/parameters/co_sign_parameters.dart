import 'package:equatable/equatable.dart';

/// Parameters for `coSignProcedure` (supervisor).
///
/// Provide EITHER [coSignCode] (the BLE/QR/manual secret — proves proximity,
/// yields Verified) OR [id] (the server-mediated fallback — no proximity proof,
/// yields the lower Attested tier).
///
/// [proximity] is free-form evidence stored for audit. Possessing the code is
/// what proves proximity; the payload only records how (BLE rssi/distance, or
/// `{method: 'QR'}` / `{method: 'MANUAL'}`).
class CoSignParameters extends Equatable {
  final String? coSignCode;
  final String? id;
  final Map<String, dynamic>? proximity;

  const CoSignParameters({this.coSignCode, this.id, this.proximity})
    : assert(
        coSignCode != null || id != null,
        'Provide a coSignCode or an id',
      );

  Map<String, dynamic> toJson() => {
    if (coSignCode != null && coSignCode!.isNotEmpty) 'coSignCode': coSignCode,
    if (id != null && id!.isNotEmpty) 'id': id,
    if (proximity != null) 'proximity': proximity,
  };

  @override
  List<Object?> get props => [coSignCode, id, proximity];
}
