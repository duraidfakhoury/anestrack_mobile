import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/hospitals_bloc/hospitals_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/procedure_types_bloc/procedure_types_bloc.dart';
// TODO: Ensure you create/import your SupervisorsBloc variations here
// import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/supervisors_bloc/supervisors_bloc.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/student/procedures/domain/parameters/create_procedure_parameters.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_bloc.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_event.dart';
import 'package:anestrack_mobile/modules/student/procedures/presentation/blocs/create_procedure_bloc/create_procedure_state.dart';
import 'package:intl/intl.dart';

class CreateProcedureScreen extends StatefulWidget {
  const CreateProcedureScreen({super.key});

  @override
  State<CreateProcedureScreen> createState() => _CreateProcedureScreenState();
}

class _CreateProcedureScreenState extends State<CreateProcedureScreen> {
  late CreateProcedureBloc _createProcedureBloc;
  late HospitalsBloc _fetchhospital;
  late ProcedureTypesBloc _fetchProcedurestypes;
  // Dynamic block ready for Supervisors list integration
  // late SupervisorsBloc _fetchSupervisors; 

  final _formKey = GlobalKey<FormState>();

  // Parameters track IDs from dynamic dropdown selections
  String? _selectedHospitalId;
  String? _selectedProcedureTypeId;
  String? _selectedSupervisorId;

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isOnline = true;
  DateTime? _chosenDate;

  @override
  void initState() {
    super.initState();
    _createProcedureBloc = sl<CreateProcedureBloc>();
    _fetchhospital = sl<HospitalsBloc>()..add(FetchHospitalsEvent());
    _fetchProcedurestypes = sl<ProcedureTypesBloc>()..add(FetchProcedureTypesEvent());
    // _fetchSupervisors = sl<SupervisorsBloc>()..add(FetchSupervisorsEvent());

    // Initialize with current day default formatted date string
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _chosenDate) {
      setState(() {
        _chosenDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _showConfirmPopup();
    }
  }

  void _showConfirmPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                    color: Color(0xFF0D9488),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "تأكيد الإرسال",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "هل أنت متأكد من أنك تريد إرسال هذا الإجراء للمراجعة؟",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _submitProcedure,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "نعم، إرسال",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitProcedure() {
    Navigator.pop(context);

    // Matches your updated parameter requirements schema exactly
    final parameters = CreateProcedureParameters(
      hospitalId: _selectedHospitalId!,
      procedureTypeId: _selectedProcedureTypeId!,
      patientName: _patientNameController.text.trim(),
      procedureDate: _dateController.text,
      supervisorId: _selectedSupervisorId!, 
      notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
      isOffline: !_isOnline,
    );

    _createProcedureBloc.add(SubmitCreateProcedureEvent(parameters));
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
                onPressed: () => context.pop(),
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
      body: BlocListener<CreateProcedureBloc, CreateProcedureState>(
        bloc: _createProcedureBloc,
        listener: (context, state) {
          if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: ${state.error ?? "حدث خطأ"}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.data == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إرسال الإجراء بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              context.go('/student-home/procedures');
            });
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Online status panel indicators
              Container(
                margin: const EdgeInsets.only(top: 16, right: 20, left: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isOnline ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isOnline ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isOnline ? LucideIcons.wifi : LucideIcons.wifiOff,
                      color: _isOnline ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? 'متصل بالإنترنت' : 'وضع عدم الاتصال نشط',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isOnline ? const Color(0xFF166534) : const Color(0xFF92400E),
                            ),
                          ),
                          Text(
                            _isOnline ? 'سيتم حفظ البيانات فوراً' : 'سيتم المزامنة تلقائياً عند الاتصال',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isOnline ? const Color(0xFF16A34A) : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form Block
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Dynamic Hospital Selector
                      _buildLabel("اختر المستشفى"),
                      BlocBuilder<HospitalsBloc, HospitalsState>(
                        bloc: _fetchhospital,
                        builder: (context, state) {
                          if (state.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(color: Color(0xFF0D9488)),
                              ),
                            );
                          }
                          final backendHospitals = state.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: _selectedHospitalId,
                            hint: const Text(
                              "ابحث أو اختر المستشفى",
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                            ),
                            decoration: _buildInputDecoration(prefixIcon: LucideIcons.search),
                            items: backendHospitals.map((hospital) {
                              return DropdownMenuItem<String>(
                                value: hospital.objectId.toString(),
                                child: Text(hospital.name, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedHospitalId = val),
                            validator: (value) => value == null ? 'يرجى اختيار المستشفى' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Dynamic Procedure Type Selector
                      _buildLabel("نوع الإجراء"),
                      BlocBuilder<ProcedureTypesBloc, ProcedureTypesState>(
                        bloc: _fetchProcedurestypes,
                        builder: (context, state) {
                          if (state.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(color: Color(0xFF0D9488)),
                              ),
                            );
                          }
                          final backendProcedures = state.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: _selectedProcedureTypeId,
                            hint: const Text(
                              "قائمة قابلة للبحث",
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                            ),
                            decoration: _buildInputDecoration(prefixIcon: LucideIcons.search),
                            items: backendProcedures.map((procedure) {
                              return DropdownMenuItem<String>(
                                value: procedure.objectId.toString(),
                                child: Text(procedure.name, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedProcedureTypeId = val),
                            validator: (value) => value == null ? 'يرجى اختيار نوع الإجراء' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. Dynamic Supervisor Selection Block
                      _buildLabel("المشرف المسؤول"),
                      DropdownButtonFormField<String>(
                        value: _selectedSupervisorId,
                        hint: const Text(
                          "اختر المشرف المسؤول",
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        ),
                        decoration: _buildInputDecoration(prefixIcon: LucideIcons.userCheck),
                        // Replace placeholder data with dynamic Supervisor BLoC bindings once ready
                        items: const [
                          DropdownMenuItem(value: "supervisor_id_1", child: Text("د. أحمد الرشيد")),
                          DropdownMenuItem(value: "supervisor_id_2", child: Text("د. رانيا الكيلاني")),
                        ],
                        onChanged: (val) => setState(() => _selectedSupervisorId = val),
                        validator: (value) => value == null ? 'يرجى اختيار المشرف' : null,
                      ),
                      /* Uncomment this block and match the placeholder architecture when the dynamic Supervisor standard Bloc is built
                      BlocBuilder<SupervisorsBloc, SupervisorsState>(
                        bloc: _fetchSupervisors,
                        builder: (context, state) {
                          if (state.isLoading) return const LinearProgressIndicator(color: Color(0xFF0D9488));
                          final supervisorsList = state.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: _selectedSupervisorId,
                            hint: const Text("اختر المشرف المسؤول"),
                            decoration: _buildInputDecoration(prefixIcon: LucideIcons.userCheck),
                            items: supervisorsList.map((supervisor) {
                              return DropdownMenuItem<String>(
                                value: supervisor.objectId.toString(),
                                child: Text(supervisor.name),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedSupervisorId = val),
                            validator: (value) => value == null ? 'يرجى اختيار المشرف' : null,
                          );
                        },
                      ),
                      */
                      const SizedBox(height: 16),

                      // 4. Patient Name Input (Swapped out from Patient ID identifier variations)
                      _buildLabel("اسم المريض"),
                      TextFormField(
                        controller: _patientNameController,
                        decoration: _buildInputDecoration(hint: "مثال: محمد عبد الله (الأحرف الأولى اختياري)"),
                        validator: (value) => value == null || value.trim().isEmpty ? 'يرجى إدخال اسم المريض' : null,
                      ),
                      const SizedBox(height: 16),

                      // 5. Date Selection Selector Field Component
                      _buildLabel("تاريخ الإجراء"),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: _buildInputDecoration(
                          prefixIcon: LucideIcons.calendar,
                          hint: "اختر تاريخ الإجراء",
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'يرجى اختيار التاريخ' : null,
                      ),
                      const SizedBox(height: 16),

                      // 6. Optional Notes Field Block
                      _buildLabel("ملاحظات (اختياري)", isRequired: false),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: _buildInputDecoration(hint: "أضف أي ملاحظات أو تفاصيل إضافية..."),
                      ),
                      const SizedBox(height: 32),

                      // Submission Button Context Framework
                      BlocBuilder<CreateProcedureBloc, CreateProcedureState>(
                        bloc: _createProcedureBloc,
                        builder: (context, state) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0D9488).withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: state.isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "إرسال للمراجعة",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
          children: [
            if (isRequired)
              const TextSpan(
                text: " *",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
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