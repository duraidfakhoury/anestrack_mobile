import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/modules/student/complaints/domain/parameters/create_complaint_parameters.dart';
import 'package:anestrack_mobile/modules/student/complaints/presentation/blocs/complaint_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class ComplaintBottomSheetContent extends StatefulWidget {
  const ComplaintBottomSheetContent({super.key});

  @override
  State<ComplaintBottomSheetContent> createState() =>
      _ComplaintBottomSheetContentState();
}

class _ComplaintBottomSheetContentState
    extends State<ComplaintBottomSheetContent> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  bool _agreed = false;
  bool _showAgreementError = false;
  String? _selectedCategory;

  static const _categories = <String, String>{
    'تتعلق بالمشرف': 'تتعلق بالمشرف',
    'تتعلق بالتدريب': 'تتعلق بالتدريب',
    'بيئة العمل': 'بيئة العمل',
    'تحرش أو سوء معاملة': 'تحرش أو سوء معاملة',
    'أخرى': 'أخرى',
  };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose(); // Prevents memory leak and TextEditingController error
    super.dispose();
  }

  @override
  Widget build(BuildContext modalContext) {
    return BlocConsumer<ComplaintBloc, ComplaintState>(
      listener: (blocContext, complaintState) {
        if (complaintState.isSuccess) {
          Navigator.of(modalContext).pop();
          ScaffoldMessenger.of(modalContext).showSnackBar(
            const SnackBar(content: Text('تم إرسال الشكوى بنجاح')),
          );
        } else if (complaintState.isError) {
          ScaffoldMessenger.of(modalContext).showSnackBar(
            SnackBar(content: Text(complaintState.errorMessage)),
          );
        }
      },
      builder: (blocContext, complaintState) {
        final isSubmitting = complaintState.isLoading;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.gray300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.red100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.lock,
                            color: AppColors.red600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تقديم شكوى سرية',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'سيتم إرسالها مباشرة للإدارة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slate600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.amber50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.amber200),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            color: AppColors.amber600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'معلومات سرية ومحمية',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.amber800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'هذه الشكوى سرية بالكامل وسيتم إرسالها مباشرة إلى مدير البرنامج. لن يتم مشاركة هويتك إلا إذا كان ذلك ضرورياً.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.amber700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'موضوع الشكوى *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      items: _categories.keys
                          .map(
                            (label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ),
                          )
                          .toList(),
                      onChanged: isSubmitting
                          ? null
                          : (value) => setState(() {
                                _selectedCategory = value;
                              }),
                      validator: (value) =>
                          value == null ? 'اختر نوع الشكوى' : null,
                      decoration: _inputDecoration(
                        hintText: 'اختر نوع الشكوى',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تفاصيل الشكوى *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controller,
                      maxLines: 6,
                      decoration: _inputDecoration(
                        hintText: 'اكتب تفاصيل الشكوى هنا...',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'اكتب تفاصيل الشكوى'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          onChanged: (value) => setState(() {
                            _agreed = value ?? false;
                            if (_agreed) {
                              _showAgreementError = false;
                            }
                          }),
                        ),
                        const Expanded(
                          child: Text(
                            'أوافق على إرسال هذه الشكوى وأفهم أنها سرية ومحمية',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.slate600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showAgreementError)
                      const Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 8),
                        child: Text(
                          'يرجى الموافقة على الإقرار',
                          style: TextStyle(
                            color: AppColors.red600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                final isValid =
                                    _formKey.currentState?.validate() ?? false;
                                if (!_agreed) {
                                  setState(() {
                                    _showAgreementError = true;
                                  });
                                  return;
                                }
                                if (!isValid) return;

                                blocContext.read<ComplaintBloc>().add(
                                      SubmitComplaintEvent(
                                        CreateComplaintParameters(
                                          title: _selectedCategory ?? 'أخرى',
                                          description:
                                              _controller.text.trim(),
                                        ),
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red600,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(LucideIcons.send, size: 18),
                        label: Text(
                          isSubmitting ? 'جارٍ الإرسال...' : 'إرسال الشكوى',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(modalContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.slate700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(color: AppColors.gray200),
                          backgroundColor: AppColors.gray100,
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
InputDecoration _inputDecoration({required String hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.slate500, fontSize: 12),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.gray200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.gray200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.studentPrimary, width: 1.5),
    ),
  );
}