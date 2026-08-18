import 'dart:convert';
import 'dart:io';

import 'package:anestrack_mobile/modules/student/procedures/domain/entities/create_procedure_result.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/hospitals_bloc/hospitals_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedure_types_bloc/procedure_types_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/supervisors_bloc/supervisors_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/routes/co_sign_handoff_route.dart';
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
import 'package:intl/intl.dart';

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
  String? _selectedProcedureTypeId;
  String? _selectedSupervisorId;

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isOnline = true;
  bool _requestLiveCoSign = false;
  bool _isEmergency = false;
  DateTime? _chosenDate;

  String? _photoBase64; // no data-URI prefix
  String? _photoPath; // for preview

  @override
  void initState() {
    super.initState();
    _createProcedureBloc = sl<CreateProcedureBloc>();
    _hospitalsBloc = sl<HospitalsBloc>()..add(FetchHospitalsEvent());
    _procedureTypesBloc = sl<ProcedureTypesBloc>()
      ..add(FetchProcedureTypesEvent());
    _supervisorsBloc = sl<SupervisorsBloc>()..add(FetchSupervisorsEvent());

    _chosenDate = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_chosenDate!);
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _createProcedureBloc.close();
    super.dispose();
  }

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

    final parameters = CreateProcedureParameters(
      hospitalId: _selectedHospitalId!,
      procedureTypeId: _selectedProcedureTypeId!,
      patientName: _patientNameController.text.trim(),
      procedureDate: _dateController.text,
      supervisorId: _selectedSupervisorId,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      isOffline: !_isOnline,
      requestLiveCoSign: _requestLiveCoSign,
      isEmergency: _isEmergency,
      photo: _photoBase64,
    );

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
            _onCreated(state.data!);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildConnectivityBanner(),
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

                        _buildLabel("نوع الإجراء"),
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

                        _buildLabel("تاريخ الإجراء"),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: _decoration(
                            prefixIcon: LucideIcons.calendar,
                            hint: "اختر تاريخ الإجراء",
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'يرجى اختيار التاريخ'
                              : null,
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

  Widget _buildConnectivityBanner() {
    return GestureDetector(
      onTap: () => setState(() => _isOnline = !_isOnline),
      child: Container(
        margin: const EdgeInsets.only(top: 16, right: 20, left: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isOnline ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isOnline
                ? const Color(0xFFBBF7D0)
                : const Color(0xFFFDE68A),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isOnline ? LucideIcons.wifi : LucideIcons.wifiOff,
              color: _isOnline
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFD97706),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOnline ? 'متصل بالإنترنت' : 'وضع عدم الاتصال',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isOnline
                          ? const Color(0xFF166534)
                          : const Color(0xFF92400E),
                    ),
                  ),
                  Text(
                    _isOnline ? 'سيتم الحفظ فوراً' : 'سيُسجّل كإدخال دون اتصال',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isOnline
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                  value: h.objectId,
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
        return DropdownButtonFormField<String>(
          value: _selectedProcedureTypeId,
          isExpanded: true,
          hint: const Text("اختر نوع الإجراء", style: _hintStyle),
          decoration: _decoration(prefixIcon: LucideIcons.stethoscope),
          items: types
              .map(
                (t) => DropdownMenuItem<String>(
                  value: t.objectId,
                  child: Text(t.name, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedProcedureTypeId = v),
          validator: (v) => v == null ? 'يرجى اختيار نوع الإجراء' : null,
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
        return DropdownButtonFormField<String>(
          value: _selectedSupervisorId,
          isExpanded: true,
          hint: const Text("اختر المشرف المسؤول", style: _hintStyle),
          decoration: _decoration(prefixIcon: LucideIcons.userCheck),
          items: supervisors
              .map(
                (s) => DropdownMenuItem<String>(
                  value: s.objectId,
                  child: Text(s.name, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedSupervisorId = v),
          // Optional: without a supervisor a non-live log stays unconfirmed,
          // and the backend accepts it either way.
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
