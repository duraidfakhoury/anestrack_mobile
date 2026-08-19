import 'package:equatable/equatable.dart';

class GetSupervisorDashboardParameters extends Equatable {
  final String? hospitalId;

  const GetSupervisorDashboardParameters({this.hospitalId});

  Map<String, dynamic> toJson() => {
    if (hospitalId != null) 'hospitalId': hospitalId,
  };

  @override
  List<Object?> get props => [hospitalId];
}
