import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/common/announcements/domain/parameters/create_announcement_parameters.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/blocs/create_announcement_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const _targetGroups = ['all', 'students', 'supervisors'];

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  late final CreateAnnouncementBloc _bloc;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _targetGroup = 'all';
  bool _isImportant = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<CreateAnnouncementBloc>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _bloc.close();
    super.dispose();
  }

  String _targetGroupLabel(String value) {
    switch (value) {
      case 'students':
        return LocaleKeys.supervisor_academic_target_students.tr();
      case 'supervisors':
        return LocaleKeys.supervisor_academic_target_supervisors.tr();
      default:
        return LocaleKeys.supervisor_academic_target_all.tr();
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _bloc.add(
      SubmitCreateAnnouncementEvent(
        CreateAnnouncementParameters(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          targetGroup: _targetGroup,
          isImportant: _isImportant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        foregroundColor: AppColors.slate900,
        title: Text(LocaleKeys.supervisor_academic_create_announcement_title.tr()),
      ),
      body: BlocConsumer<CreateAnnouncementBloc, CreateAnnouncementState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.red600,
              ),
            );
          } else if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocaleKeys.supervisor_academic_create_announcement_success
                      .tr(),
                ),
                backgroundColor: AppColors.supervisorPrimary,
              ),
            );
            context.pop(true);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(LocaleKeys.supervisor_academic_field_announcement_title.tr()),
                  TextFormField(
                    controller: _titleController,
                    decoration: _decoration(
                      hint: LocaleKeys
                          .supervisor_academic_field_announcement_title_hint
                          .tr(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? LocaleKeys.supervisor_academic_required_field.tr()
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _Label(
                    LocaleKeys.supervisor_academic_field_announcement_content
                        .tr(),
                  ),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: _decoration(
                      hint: LocaleKeys
                          .supervisor_academic_field_announcement_content_hint
                          .tr(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? LocaleKeys.supervisor_academic_required_field.tr()
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _Label(LocaleKeys.supervisor_academic_field_target_group.tr()),
                  DropdownButtonFormField<String>(
                    initialValue: _targetGroup,
                    isExpanded: true,
                    decoration: _decoration(),
                    items: _targetGroups
                        .map(
                          (g) => DropdownMenuItem<String>(
                            value: g,
                            child: Text(
                              _targetGroupLabel(g),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _targetGroup = v!),
                  ),
                  const SizedBox(height: 8),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isImportant,
                    onChanged: (v) => setState(() => _isImportant = v),
                    activeTrackColor: AppColors.supervisorPrimary,
                    title: Text(
                      LocaleKeys.supervisor_academic_mark_important.tr(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.supervisorPrimary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: state.isLoading ? null : _submit,
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              LocaleKeys
                                  .supervisor_academic_create_announcement_submit
                                  .tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.supervisorPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red600, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red600, width: 2),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.slate600,
        ),
      ),
    );
  }
}
