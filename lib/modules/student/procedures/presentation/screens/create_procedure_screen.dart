import 'dart:convert';
import 'dart:io';

import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/offline_cosign_qr_payload.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/entities/procedure_type.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/hospitals_bloc/hospitals_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedure_types_bloc/procedure_types_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/supervisors_bloc/supervisors_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/co_sign_handoff_route.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/offline_cosign_scan_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_state.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedures_bloc/procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/pending_procedures_bloc/pending_procedures_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/queued_cosigned_procedures_bloc/queued_cosigned_procedures_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/queued_cosigned_procedures_bloc/queued_cosigned_procedures_event.dart';

const _teal = Color(0xFF0D9488);
const _cyan = Color(0xFF0891B2);

class CreateProcedureScreen extends StatefulWidget {
  const CreateProcedureScreen({super.key});

  @override
  State<CreateProcedureScreen> createState() => _CreateProcedureScreenState();
}

class _CreateProcedureScreenState extends State<CreateProcedureScreen> {
  late CreateProcedureBloc _createProcedureBloc;
  late HospitalsBloc _hospitalsBloc;
  late ProcedureTypesBloc _procedureTypesBloc;
  late SupervisorsBloc _supervisorsBloc;

  final _formKey = GlobalKey<FormState>();

  String? _selectedHospitalId;
  final Set<String> _selectedProcedureTypeIds = {};
  String? _selectedSupervisorId;

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _procedureTypeSearchController =
      TextEditingController();
  String _procedureTypeSearchQuery = '';
  String _procedureTypeCategoryFilter = 'all';

  bool _requestLiveCoSign = false;
  bool _isEmergency = false;
  DateTime? _chosenDate;
  TimeOfDay? _chosenTime;

  /// Whether the student touched the date/time pickers. Until they do, we
  /// submit the actual moment of submission (not whatever `DateTime.now()`
  /// was when the screen opened) — only an explicit edit here means a
  /// backdated procedure.
  bool _dateTimeManuallyChanged = false;

  String? _photoBase64; // no data-URI prefix
  String? _photoPath; // for preview

  /// The parameters from the submit attempt that just came back offline —
  /// kept so the offline co-sign prompt can re-dispatch them once the
  /// student picks "scan" or "skip". Cleared once handled.
  CreateProcedureParameters? _pendingOfflineParameters;

  @override
  void initState() {
    super.initState();
    _createProcedureBloc = sl<CreateProcedureBloc>();
    _hospitalsBloc = sl<HospitalsBloc>()..add(FetchHospitalsEvent());
    _procedureTypesBloc = sl<ProcedureTypesBloc>()
      ..add(FetchProcedureTypesEvent());
    _supervisorsBloc = sl<SupervisorsBloc>()..add(FetchSupervisorsEvent());

    _chosenDate = DateTime.now();
    _chosenTime = TimeOfDay.fromDateTime(_chosenDate!);
    _dateController.text = DateFormat('yyyy-MM-dd').format(_chosenDate!);
    _timeController.text = _formatTime(_chosenTime!);
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _procedureTypeSearchController.dispose();
    _createProcedureBloc.close();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _chosenDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _teal,
            onPrimary: Colors.white,
            onSurface: Color(0xFF1F2937),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _chosenDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _dateTimeManuallyChanged = true;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _chosenTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _teal,
            onPrimary: Colors.white,
            onSurface: Color(0xFF1F2937),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _chosenTime = picked;
        _timeController.text = _formatTime(picked);
        _dateTimeManuallyChanged = true;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800, // Dropped slightly to guarantee smaller payload
      maxHeight: 800,
      imageQuality: 60, // 60% quality is plenty for medical log photos
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();

    // 1. Convert to raw base64
    String rawBase64 = base64Encode(bytes);

    // 2. STRIP ALL NEWLINES (\r and \n) AND SPACES
    String cleanBase64 = rawBase64.replaceAll(RegExp(r'[\r\n\s]'), '');

    setState(() {
      _photoBase64 = 'data:image/jpeg;base64,$cleanBase64';
      _photoPath = file.path;
    });
  }

  void _removePhoto() {
    setState(() {
      _photoBase64 = null;
      _photoPath = null;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _showConfirmPopup();
    }
  }

  void _submitProcedure() {
    Navigator.pop(context);

    final DateTime procedureDateTime = _dateTimeManuallyChanged
        ? DateTime(
            _chosenDate!.year,
            _chosenDate!.month,
            _chosenDate!.day,
            _chosenTime!.hour,
            _chosenTime!.minute,
          )
        : DateTime.now();

    final parameters = CreateProcedureParameters(
      hospitalId: _selectedHospitalId!,
      procedureTypeIds: _selectedProcedureTypeIds.toList(),
      patientName: _patientNameController.text.trim(),
      procedureDate: procedureDateTime.toIso8601String(),
      supervisorId: _selectedSupervisorId,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      requestLiveCoSign: _requestLiveCoSign,
      isEmergency: _isEmergency,
      photo: _photoBase64,
    );

    _pendingOfflineParameters = parameters;
    _createProcedureBloc.add(SubmitCreateProcedureEvent(parameters));
  }

  void _onCreated(CreateProcedureResult result) {
    // The procedure already exists server-side at this point (even for the
    // live co-sign flow), so refresh the list the student will land back on.
    sl<ProceduresBloc>().add(const RefreshProceduresEvent());

    if (result.requiresLiveCoSign) {
      // Flow 1: hand the co-sign code to the supervisor.
      context.push(CoSignHandoffRoute.name, extra: result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الإجراء بنجاح'),
          backgroundColor: Color(0xFF2E9E6B),
        ),
      );
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) context.go('/student-home/procedures');
      });
    }
  }

  // Device was offline at submission time — saved locally instead of sent.
  void _onQueuedOffline() {
    sl<PendingProceduresBloc>().add(const RefreshPendingProceduresEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم الحفظ محلياً — سيتم المزامنة تلقائياً عند عودة الاتصال'),
        backgroundColor: Color(0xFFD97706),
      ),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) context.go('/student-home/procedures');
    });
  }

  // The student scanned a supervisor's bedside QR while offline — queued to
  // the offline co-sign queue instead of the plain one.
  void _onQueuedCoSigned() {
    sl<QueuedCosignedProceduresBloc>().add(
      const RefreshQueuedCosignedProceduresEvent(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.offline_cosign_offline_queued_success.tr()),
        backgroundColor: const Color(0xFF2E9E6B),
      ),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) context.go('/student-home/procedures');
    });
  }

  // The online submit attempt just failed with no connectivity — nothing
  // has been queued yet. Ask the student whether to attach a supervisor's
  // bedside code (offline co-sign) or save without one
  // (`integration-mobile-offline-cosign.md` §5).
  Future<void> _showOfflineCoSignPrompt() async {
    final parameters = _pendingOfflineParameters;
    if (parameters == null) return;

    if (!parameters.requestLiveCoSign) {
      // The student never checked "request live co-sign" — they aren't
      // claiming a supervisor is physically present at the bedside, so
      // there's nothing to offer a QR scan for. Queue straight to the
      // plain offline queue, same as before this feature existed.
      _pendingOfflineParameters = null;
      _createProcedureBloc.add(QueuePlainOfflineProcedureEvent(parameters));
      return;
    }

    final choice = await showModalBottomSheet<_OfflinePromptChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _OfflineCoSignPromptSheet(),
    );
    if (!mounted) return;

    switch (choice) {
      case _OfflinePromptChoice.scan:
        final payload = await context.push<OfflineCoSignQrPayload>(
          OfflineCoSignScanRoute.name,
        );
        if (!mounted) return;
        if (payload != null) {
          _pendingOfflineParameters = null;
          _createProcedureBloc.add(
            QueueCoSignedOfflineProcedureEvent(parameters, payload),
          );
        } else {
          // Backed out of scanning — re-offer the choice rather than
          // silently dropping the entry.
          await _showOfflineCoSignPrompt();
        }
      case _OfflinePromptChoice.skip:
        _pendingOfflineParameters = null;
        _createProcedureBloc.add(QueuePlainOfflineProcedureEvent(parameters));
      case null:
        // Dismissed — leave the form as-is; the student can tap submit
        // again whenever they're ready.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  LucideIcons.arrowRight,
                  color: Color(0xFF374151),
                ),
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go('/student-home/procedures'),
              ),
              const Text(
                "تسجيل إجراء جديد",
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<CreateProcedureBloc, CreateProcedureState>(
        bloc: _createProcedureBloc,
        listener: (context, state) {
          if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: ${state.errorMessage}'),
                backgroundColor: const Color(0xFFC1483F),
              ),
            );
          } else if (state.isSuccess && state.data != null) {
            final data = state.data!;
            if (data.offlineNeedsDecision) {
              _showOfflineCoSignPrompt();
            } else if (data.queuedOffline) {
              if (data.queuedCoSigned) {
                _onQueuedCoSigned();
              } else {
                _onQueuedOffline();
              }
            } else {
              _onCreated(data);
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("اختر المستشفى"),
                        _buildHospitalDropdown(),
                        const SizedBox(height: 16),

                        _buildLabel("أنواع الإجراء (يمكن اختيار أكثر من نوع)"),
                        _buildProcedureTypeDropdown(),
                        const SizedBox(height: 16),

                        _buildLabel("اسم المريض"),
                        TextFormField(
                          controller: _patientNameController,
                          decoration: _decoration(
                            hint: "مثال: محمد ع. (الأحرف الأولى تكفي)",
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'يرجى إدخال اسم المريض'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("تاريخ ووقت الإجراء"),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: _decoration(
                                  prefixIcon: LucideIcons.calendar,
                                  hint: "التاريخ",
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'يرجى اختيار التاريخ'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _timeController,
                                readOnly: true,
                                onTap: () => _selectTime(context),
                                decoration: _decoration(
                                  prefixIcon: LucideIcons.clock,
                                  hint: "الوقت",
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'يرجى اختيار الوقت'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dateTimeManuallyChanged
                              ? "تم تعديل الوقت — سيُسجَّل الإجراء بتاريخ ووقت مختلفين عن الآن"
                              : "افتراضياً: الوقت الحالي — يمكنك تعديله لتسجيل إجراء سابق",
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildFlowSection(),
                        const SizedBox(height: 16),

                        _buildLabel(
                          _requestLiveCoSign
                              ? "المشرف (اختياري مع التوقيع المباشر)"
                              : "المشرف المسؤول",
                          isRequired: false,
                        ),
                        _buildSupervisorDropdown(),
                        const SizedBox(height: 16),

                        _buildLabel("صورة الجسم (اختياري)", isRequired: false),
                        _buildPhotoPicker(),
                        const SizedBox(height: 16),

                        _buildLabel("ملاحظات (اختياري)", isRequired: false),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: _decoration(
                            hint: "أضف أي تفاصيل إضافية...",
                          ),
                        ),
                        const SizedBox(height: 28),

                        _buildSubmitButton(state.isLoading),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlowSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCFE6E8)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: _teal,
            value: _requestLiveCoSign,
            onChanged: (v) => setState(() => _requestLiveCoSign = v),
            title: const Text(
              'طلب توقيع مباشر',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Text(
              'المشرف بجانبك الآن — توقيع بلمسة واحدة (موثّق)',
              style: TextStyle(fontSize: 12, color: Color(0xFF5B6B73)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCFE6E8)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFFC1483F),
            value: _isEmergency,
            onChanged: (v) => setState(() => _isEmergency = v),
            title: const Text(
              'حالة طارئة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Text(
              'لا يوجد مشرف حاضر — يؤكدها المشرف المناوب لاحقاً',
              style: TextStyle(fontSize: 12, color: Color(0xFF5B6B73)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker() {
    if (_photoBase64 == null) {
      return OutlinedButton.icon(
        onPressed: _pickPhoto,
        style: OutlinedButton.styleFrom(
          foregroundColor: _teal,
          side: const BorderSide(color: Color(0xFFCFE6E8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(LucideIcons.camera, size: 18),
        label: const Text('إضافة صورة (غير معرِّفة للهوية) +ثقة'),
      );
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(_photoPath!),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'تم إرفاق الصورة',
            style: TextStyle(fontSize: 13, color: Color(0xFF166534)),
          ),
        ),
        IconButton(
          onPressed: _removePhoto,
          icon: const Icon(LucideIcons.trash2, color: Color(0xFFC1483F)),
        ),
      ],
    );
  }

  Widget _buildHospitalDropdown() {
    return BlocBuilder<HospitalsBloc, HospitalsState>(
      bloc: _hospitalsBloc,
      builder: (context, state) {
        if (state.isLoading) return const _LoadingBar();
        final hospitals = state.data ?? [];
        return DropdownButtonFormField<String>(
          value: _selectedHospitalId,
          isExpanded: true,
          hint: const Text("اختر المستشفى", style: _hintStyle),
          decoration: _decoration(prefixIcon: LucideIcons.building2),
          items: hospitals
              .map(
                (h) => DropdownMenuItem<String>(
                  value: h.id,
                  child: Text(h.name, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedHospitalId = v),
          validator: (v) => v == null ? 'يرجى اختيار المستشفى' : null,
        );
      },
    );
  }

  Widget _buildProcedureTypeDropdown() {
    return BlocBuilder<ProcedureTypesBloc, ProcedureTypesState>(
      bloc: _procedureTypesBloc,
      builder: (context, state) {
        if (state.isLoading) return const _LoadingBar();
        final types = state.data ?? [];
        final byCategory = _procedureTypeCategoryFilter == 'all'
            ? types
            : types.where((t) => t.category == _procedureTypeCategoryFilter).toList();
        final query = _procedureTypeSearchQuery.trim();
        final filtered = query.isEmpty
            ? byCategory
            : byCategory
                  .where(
                    (t) => (t.nameAr ?? t.name).toLowerCase().contains(
                      query.toLowerCase(),
                    ),
                  )
                  .toList();
        return FormField<Set<String>>(
          initialValue: _selectedProcedureTypeIds,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'يرجى اختيار نوع إجراء واحد على الأقل' : null,
          builder: (field) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: field.hasError
                      ? Colors.red
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedProcedureTypeIds.isNotEmpty) ...[
                    Text(
                      'تم اختيار ${_selectedProcedureTypeIds.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _CategoryFilterChip(
                        label: 'الكل',
                        selected: _procedureTypeCategoryFilter == 'all',
                        onTap: () =>
                            setState(() => _procedureTypeCategoryFilter = 'all'),
                      ),
                      _CategoryFilterChip(
                        label: 'إجراءات',
                        selected: _procedureTypeCategoryFilter ==
                            ProcedureCategories.procedure,
                        onTap: () => setState(
                          () => _procedureTypeCategoryFilter =
                              ProcedureCategories.procedure,
                        ),
                      ),
                      _CategoryFilterChip(
                        label: 'تقنيات',
                        selected: _procedureTypeCategoryFilter ==
                            ProcedureCategories.technique,
                        onTap: () => setState(
                          () => _procedureTypeCategoryFilter =
                              ProcedureCategories.technique,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _procedureTypeSearchController,
                    onChanged: (v) =>
                        setState(() => _procedureTypeSearchQuery = v),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'ابحث عن نوع الإجراء',
                      hintStyle: _hintStyle,
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        size: 18,
                        color: Color(0xFF9CA3AF),
                      ),
                      suffixIcon: _procedureTypeSearchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(LucideIcons.x, size: 16),
                              onPressed: () => setState(() {
                                _procedureTypeSearchController.clear();
                                _procedureTypeSearchQuery = '';
                              }),
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: filtered.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'لا توجد نتائج',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: filtered.map((t) {
                                final selected = _selectedProcedureTypeIds
                                    .contains(t.id);
                                return FilterChip(
                                  label: Text(
                                    t.nameAr ?? t.name,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  selected: selected,
                                  selectedColor: const Color(0xFFCCFBF1),
                                  checkmarkColor: _teal,
                                  backgroundColor: const Color(0xFFF9FAFB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: selected
                                          ? _teal
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  onSelected: (v) => setState(() {
                                    if (v) {
                                      _selectedProcedureTypeIds.add(t.id);
                                    } else {
                                      _selectedProcedureTypeIds.remove(t.id);
                                    }
                                    field.didChange(_selectedProcedureTypeIds);
                                  }),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        field.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSupervisorDropdown() {
    return BlocBuilder<SupervisorsBloc, SupervisorsState>(
      bloc: _supervisorsBloc,
      builder: (context, state) {
        if (state.isLoading) return const _LoadingBar();
        final supervisors = state.data ?? [];

        // Check if _selectedSupervisorId exists in the loaded list
        final hasMatchingSupervisor = supervisors.any(
          (s) => s.id == _selectedSupervisorId,
        );
        final validSelectedId = hasMatchingSupervisor
            ? _selectedSupervisorId
            : null;

        return DropdownButtonFormField<String>(
          value: validSelectedId, // Ensures value is null if invalid or missing
          isExpanded: true,
          hint: const Text("اختر المشرف المسؤول", style: _hintStyle),
          decoration: _decoration(prefixIcon: LucideIcons.userCheck),
          items: supervisors
              .map(
                (s) => DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(s.fullName, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedSupervisorId = v),
          validator: (v) {
            if (!_requestLiveCoSign && v == null) {
              return 'اختر مشرفاً ليؤكّد الإجراء (أو فعّل التوقيع المباشر)';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_teal, _cyan]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                _requestLiveCoSign ? "تسجيل وطلب التوقيع" : "تسجيل الإجراء",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _showConfirmPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFCCFBF1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.alertCircle,
                  color: _teal,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "تأكيد التسجيل",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _requestLiveCoSign
                    ? "سيُنشأ رمز توقيع لمرة واحدة لتسليمه للمشرف بجانبك."
                    : "هل تريد تسجيل هذا الإجراء؟",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitProcedure,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "نعم، تسجيل",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "إلغاء",
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: " *",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _hintStyle,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

const _hintStyle = TextStyle(color: Color(0xFF9CA3AF), fontSize: 14);

enum _OfflinePromptChoice { scan, skip }

/// "You're offline" prompt shown after a submit attempt fails with no
/// connectivity — lets the student attach a supervisor's bedside QR
/// (offline co-sign) before the entry is queued, or save without one.
/// See `integration-mobile-offline-cosign.md` §5.
class _OfflineCoSignPromptSheet extends StatelessWidget {
  const _OfflineCoSignPromptSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF4E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.wifiOff, color: Color(0xFFD98C2B)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  LocaleKeys.offline_cosign_offline_prompt_title.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.offline_cosign_offline_prompt_body.tr(),
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF5B6B73)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pop(context, _OfflinePromptChoice.scan),
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(LucideIcons.qrCode, size: 18),
            label: Text(LocaleKeys.offline_cosign_offline_prompt_scan_button.tr()),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () =>
                Navigator.pop(context, _OfflinePromptChoice.skip),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(LocaleKeys.offline_cosign_offline_prompt_skip_button.tr()),
          ),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: LinearProgressIndicator(color: _teal),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: _teal,
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF4B5563),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Colors.transparent : const Color(0xFFE5E7EB),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
