import 'package:equatable/equatable.dart';

class SupervisorHomeTile extends Equatable {
  final String title;
  final String subtitle;
  final String iconKey;
  final int colorValue;

  const SupervisorHomeTile({
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [title, subtitle, iconKey, colorValue];
}
