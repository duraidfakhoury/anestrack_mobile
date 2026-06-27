import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SupervisorAcadamicScreen extends StatelessWidget {
  const SupervisorAcadamicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Text(
          'nav.library'.tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
