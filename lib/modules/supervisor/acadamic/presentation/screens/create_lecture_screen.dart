import 'dart:convert';

import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/education/domain/parameters/create_lecture_parameters.dart';
import 'package:anestrack_mobile/modules/student/education/presentation/widgets/lecture_widgets.dart';
import 'package:anestrack_mobile/modules/supervisor/acadamic/presentation/blocs/create_lecture_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Inline base64 route caps at ~7 MB of real file: the JSON body limit is
// 10 MB and base64 inflates by a third (integration §7A). Larger documents /
// videos are published via a URL instead.
const _maxFileSizeBytes = 7 * 1024 * 1024;

const _contentTypes = ['Video', 'Document', 'Text'];

const _documentExtensions = ['pdf', 'doc', 'docx', 'ppt', 'pptx'];

class CreateLectureScreen extends StatefulWidget {
  const CreateLectureScreen({super.key});

  @override
  State<CreateLectureScreen> createState() => _CreateLectureScreenState();
}

class _CreateLectureScreenState extends State<CreateLectureScreen> {
  late final CreateLectureBloc _bloc;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentUrlController = TextEditingController();
  final TextEditingController _mainGoalsController = TextEditingController();

  String _contentType = 'Video';
  String? _fileBase64;
  String? _fileName;
  String? _fileError;
  bool _withTest = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<CreateLectureBloc>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentUrlController.dispose();
    _mainGoalsController.dispose();
    _bloc.close();
    super.dispose();
  }

  bool get _isDocument => _contentType == 'Document';
  bool get _isText => _contentType == 'Text';

  String get _contentFieldLabel => _isText
      ? LocaleKeys.supervisor_academic_field_lecture_text.tr()
      : LocaleKeys.supervisor_academic_field_video_url.tr();

  String get _contentFieldHint => _isText
      ? LocaleKeys.supervisor_academic_field_lecture_text_hint.tr()
      : LocaleKeys.supervisor_academic_field_video_url_hint.tr();

  Future<void> _pickFile() async {
    final files = await FilePickerPlatform.instance.pickFiles(
      type: FileType.custom,
      allowedExtensions: _documentExtensions,
    );
    if (files.isEmpty) return;
    final picked = files.first;

    final bytes = await picked.readAsBytes();

    if (bytes.lengthInBytes > _maxFileSizeBytes) {
      setState(() {
        _fileError = LocaleKeys.supervisor_academic_file_too_large.tr();
        _fileBase64 = null;
        _fileName = null;
      });
      return;
    }

    // Raw base64 (no data-URI prefix) — createLecture expects
    // file: {base64, name} (integration §7A).
    final base64Body = base64Encode(bytes).replaceAll(RegExp(r'[\r\n\s]'), '');
    setState(() {
      _fileBase64 = base64Body;
      _fileName = picked.name;
      _fileError = null;
    });
  }

  void _removeFile() {
    setState(() {
      _fileBase64 = null;
      _fileName = null;
      _fileError = null;
    });
  }

  void _submit() {
    final isFormValid = _formKey.currentState!.validate();

    // A Document is published as an uploaded file; Text/Video use the text
    // field (body / external URL respectively).
    var hasError = false;
    if (_isDocument && (_fileBase64 == null || _fileBase64!.isEmpty)) {
      _fileError = LocaleKeys.supervisor_academic_attach_document_file.tr();
      hasError = true;
    }

    if (!isFormValid || hasError) {
      setState(() {});
      return;
    }

    final goals = _mainGoalsController.text
        .split('\n')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
    final contentField = _contentUrlController.text.trim();

    _bloc.add(
      SubmitCreateLectureEvent(
        CreateLectureParameters(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          contentType: _contentType,
          contentText: _isText ? contentField : null,
          contentUrl: (!_isText && !_isDocument) ? contentField : null,
          file: _isDocument && _fileBase64 != null
              ? LectureUploadFile.base64(
                  base64: _fileBase64!,
                  name: _fileName ?? 'document',
                )
              : null,
          mainGoals: goals,
          withTest: _withTest,
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
        title: Text(LocaleKeys.supervisor_academic_create_lecture_title.tr()),
      ),
      body: BlocConsumer<CreateLectureBloc, CreateLectureState>(
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
                  LocaleKeys.supervisor_academic_create_lecture_success.tr(),
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
                  _Label(LocaleKeys.library_field_title.tr()),
                  TextFormField(
                    controller: _titleController,
                    decoration: _decoration(),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? LocaleKeys.supervisor_academic_required_field.tr()
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _Label(LocaleKeys.library_field_description.tr()),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: _decoration(),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? LocaleKeys.supervisor_academic_required_field.tr()
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _Label(LocaleKeys.supervisor_academic_field_content_type.tr()),
                  DropdownButtonFormField<String>(
                    initialValue: _contentType,
                    isExpanded: true,
                    decoration: _decoration(),
                    items: _contentTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              lectureContentTypeLabel(type),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _contentType = v!),
                  ),
                  const SizedBox(height: 16),

                  if (_isDocument) ...[
                    _Label(LocaleKeys.supervisor_academic_field_document_file.tr()),
                    _buildFilePicker(),
                    if (_fileError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _fileError!,
                          style: const TextStyle(
                            color: AppColors.red600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ] else ...[
                    _Label(_contentFieldLabel),
                    TextFormField(
                      controller: _contentUrlController,
                      maxLines: _isText ? 6 : 1,
                      decoration: _decoration(hint: _contentFieldHint),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? LocaleKeys.supervisor_academic_required_field.tr()
                          : null,
                    ),
                  ],
                  const SizedBox(height: 16),

                  _Label(LocaleKeys.supervisor_academic_field_main_goals.tr()),
                  TextFormField(
                    controller: _mainGoalsController,
                    maxLines: 4,
                    decoration: _decoration(
                      hint: LocaleKeys
                          .supervisor_academic_field_main_goals_hint
                          .tr(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _withTest,
                    activeThumbColor: AppColors.supervisorPrimary,
                    title: Text(
                      LocaleKeys.supervisor_academic_field_with_test.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate600,
                      ),
                    ),
                    onChanged: (v) => setState(() => _withTest = v),
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
                              LocaleKeys.supervisor_academic_create_lecture_submit
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

  Widget _buildFilePicker() {
    if (_fileName == null) {
      return OutlinedButton.icon(
        onPressed: _pickFile,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.supervisorPrimary,
          side: const BorderSide(color: AppColors.gray100),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(LucideIcons.upload, size: 18),
        label: Text(LocaleKeys.supervisor_academic_pick_document.tr()),
      );
    }
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.blue100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.fileText,
            color: AppColors.blue600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _fileName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.slate600),
          ),
        ),
        TextButton(
          onPressed: _pickFile,
          child: Text(LocaleKeys.supervisor_academic_replace_file.tr()),
        ),
        IconButton(
          onPressed: _removeFile,
          icon: const Icon(LucideIcons.trash2, color: AppColors.red600),
        ),
      ],
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
