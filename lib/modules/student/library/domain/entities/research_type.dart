import 'package:equatable/equatable.dart';

/// A research paper category (`ResearchType` Parse class).
class ResearchType extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const ResearchType({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, isActive];
}
