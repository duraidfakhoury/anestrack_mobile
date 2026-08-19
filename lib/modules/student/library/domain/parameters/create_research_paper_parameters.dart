import 'package:equatable/equatable.dart';

/// Parameters for `createResearchPaper`.
class CreateResearchPaperParameters extends Equatable {
  final String title;
  final String description;
  final List<String> authors;
  final String researchTypeId;

  /// The PDF file as a base64 data-URI string
  /// (`data:application/pdf;base64,...`).
  final String file;

  const CreateResearchPaperParameters({
    required this.title,
    required this.description,
    required this.authors,
    required this.researchTypeId,
    required this.file,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'authors': authors,
    'researchTypeId': researchTypeId,
    'file': file,
  };

  @override
  List<Object?> get props => [
    title,
    description,
    authors,
    researchTypeId,
    file,
  ];
}
