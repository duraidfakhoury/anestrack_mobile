import 'dart:convert';

import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/library/domain/entities/research_type.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/publish_research_bloc.dart';
import 'package:anestrack_mobile/modules/student/library/presentation/blocs/research_types_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _maxFileSizeBytes = 15 * 1024 * 1024; // 15 MB, matches Parse's default cap

class PublishResearchScreen extends StatefulWidget {
  const PublishResearchScreen({super.key});

  @override
  State<PublishResearchScreen> createState() => _PublishResearchScreenState();
}

class _PublishResearchScreenState extends State<PublishResearchScreen> {
  late final PublishResearchBloc _publishBloc;
  late final ResearchTypesBloc _typesBloc;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  final List<String> _authors = [];
  ResearchType? _selectedType;
  String? _fileBase64;
  String? _fileName;
  String? _fileError;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _publishBloc = sl<PublishResearchBloc>();
    _typesBloc = sl<ResearchTypesBloc>()..add(FetchResearchTypesEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _publishBloc.close();
    _typesBloc.close();
    super.dispose();
  }

  void _addAuthor() {
    final name = _authorController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _authors.add(name);
      _authorController.clear();
    });
  }

  void _removeAuthor(String name) {
    setState(() => _authors.remove(name));
  }

  Future<void> _pickFile() async {
    final files = await FilePickerPlatform.instance.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (files.isEmpty) return;
    final picked = files.first;

    final bytes = await picked.readAsBytes();

    if (bytes.lengthInBytes > _maxFileSizeBytes) {
      setState(() {
        _fileError = LocaleKeys.library_file_too_large.tr();
        _fileBase64 = null;
        _fileName = null;
      });
      return;
    }

    final base64Body = base64Encode(bytes).replaceAll(RegExp(r'[\r\n\s]'), '');
    setState(() {
      _fileBase64 = 'data:application/pdf;base64,$base64Body';
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
    _submitAttempted = true;
    final isFormValid = _formKey.currentState!.validate();
    var hasError = false;

    if (_authors.isEmpty) {
      hasError = true;
    }
    if (_selectedType == null) {
      hasError = true;
    }
    if (_fileBase64 == null) {
      _fileError = LocaleKeys.library_attach_pdf_file.tr();
      hasError = true;
    }

    if (!isFormValid || hasError) {
      setState(() {});
      return;
    }

    _publishBloc.add(
      SubmitPublishResearchEvent(
        CreateResearchPaperParameters(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          authors: _authors,
          researchTypeId: _selectedType!.id,
          file: _fileBase64!,
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
        title: Text(LocaleKeys.library_publish_title.tr()),
      ),
      body: BlocConsumer<PublishResearchBloc, PublishResearchState>(
        bloc: _publishBloc,
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
                content: Text(LocaleKeys.library_submit_success.tr()),
                backgroundColor: AppColors.studentPrimary,
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
                    decoration: _decoration(
                      hint: LocaleKeys.library_field_title_hint.tr(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? LocaleKeys.library_required_field.tr()
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _Label(LocaleKeys.library_field_description.tr()),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: _decoration(
                      hint: LocaleKeys.library_field_description_hint.tr(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? LocaleKeys.library_required_field.tr()
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _Label(LocaleKeys.library_field_authors.tr()),
                  _AuthorsInput(
                    controller: _authorController,
                    authors: _authors,
                    onAdd: _addAuthor,
                    onRemove: _removeAuthor,
                  ),
                  if (_submitAttempted && _authors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        LocaleKeys.library_add_at_least_one_author.tr(),
                        style: const TextStyle(
                          color: AppColors.red600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  _Label(LocaleKeys.library_field_research_type.tr()),
                  _buildResearchTypeDropdown(),
                  const SizedBox(height: 16),

                  _Label(LocaleKeys.library_field_file.tr()),
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
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.studentPrimary,
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
                              LocaleKeys.library_submit.tr(),
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

  Widget _buildResearchTypeDropdown() {
    return BlocBuilder<ResearchTypesBloc, ResearchTypesState>(
      bloc: _typesBloc,
      builder: (context, state) {
        if (state.isLoading) {
          return const LinearProgressIndicator(color: AppColors.studentPrimary);
        }
        final types = state.data ?? const [];
        final hasSelected = types.any((t) => t.id == _selectedType?.id);
        return DropdownButtonFormField<ResearchType>(
          value: hasSelected ? _selectedType : null,
          isExpanded: true,
          hint: Text(
            LocaleKeys.library_field_research_type_hint.tr(),
            style: const TextStyle(color: AppColors.slate400, fontSize: 14),
          ),
          decoration: _decoration(prefixIcon: LucideIcons.tag),
          items: types
              .map(
                (t) => DropdownMenuItem<ResearchType>(
                  value: t,
                  child: Text(t.name, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedType = v),
          validator: (v) =>
              v == null ? LocaleKeys.library_select_research_type.tr() : null,
        );
      },
    );
  }

  Widget _buildFilePicker() {
    if (_fileName == null) {
      return OutlinedButton.icon(
        onPressed: _pickFile,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.studentPrimary,
          side: const BorderSide(color: AppColors.gray100),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(LucideIcons.upload, size: 18),
        label: Text(LocaleKeys.library_pick_file.tr()),
      );
    }
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.purple100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.fileText,
            color: AppColors.purple600,
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
          child: Text(LocaleKeys.library_replace_file.tr()),
        ),
        IconButton(
          onPressed: _removeFile,
          icon: const Icon(LucideIcons.trash2, color: AppColors.red600),
        ),
      ],
    );
  }

  InputDecoration _decoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.slate400, size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.studentPrimary, width: 2),
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

class _AuthorsInput extends StatelessWidget {
  const _AuthorsInput({
    required this.controller,
    required this.authors,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final List<String> authors;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: LocaleKeys.library_field_authors_hint.tr(),
                  hintStyle: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gray100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.studentPrimary,
                      width: 2,
                    ),
                  ),
                ),
                onFieldSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.studentPrimary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAdd,
              child: Text(LocaleKeys.library_add_author.tr()),
            ),
          ],
        ),
        if (authors.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: authors
                .map(
                  (name) => Chip(
                    label: Text(name, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.studentPrimaryLight,
                    deleteIcon: const Icon(LucideIcons.x, size: 14),
                    onDeleted: () => onRemove(name),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
