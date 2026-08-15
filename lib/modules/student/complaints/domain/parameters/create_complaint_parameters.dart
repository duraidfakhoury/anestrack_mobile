import 'package:equatable/equatable.dart';

class CreateComplaintParameters extends Equatable {
  final String title;
  final String description;

  const CreateComplaintParameters({
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };

  @override
  List<Object?> get props => [title, description];
}
