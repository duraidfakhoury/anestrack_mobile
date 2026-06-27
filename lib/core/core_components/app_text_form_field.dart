import 'package:anestrack_mobile/core/extensions/app_text_field_theme.dart';
import 'package:anestrack_mobile/core/extensions/theme_text_style.dart';
import 'package:anestrack_mobile/core/services/screen_size_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import '../constants/app_colors.dart';

class AppTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final Widget? icon;
  final bool isPass;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final BorderRadius? borderRadius;
  final Widget? prefixIcon;
  final EdgeInsets? padding;
  final EdgeInsets? contentPadding;
  final bool readOnly;
  final void Function(String)? onChanged;
  final GlobalKey<FormState> formKey;
  final InputDecorationThemeData? inputDecorationTheme;

  final String? label;
  final TextStyle? style;
  final VoidCallback? onTap;

  final bool required;
  final int? maxLength;

  final bool onlyNumbers;
  final bool isPrice;

  final void Function(String value)? onFieldSubmitted;
  final TextDirection? textDirection;

  const AppTextFormField({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.maxLength,
    this.keyboardType,
    this.isPass = false,
    this.validator,
    this.borderRadius,
    this.padding,
    this.prefixIcon,
    this.readOnly = false,
    this.onChanged,
    required this.formKey,
    this.label,
    this.onFieldSubmitted,
    this.inputDecorationTheme,
    this.contentPadding,
    this.style,
    this.onTap,
    this.isPrice = false,
    this.required = true,
    this.onlyNumbers = false,
    this.textDirection,
  });

  factory AppTextFormField.large(
    context, {
    required GlobalKey<FormState> formKey,
    required String hint,
    TextEditingController? controller,
    String? Function(String? value)? validator,
    TextInputType? keyboardType,
    EdgeInsets? padding,
    void Function(String value)? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? icon,
    bool onlyNumbers = false,
    bool isPrice = false,
  }) {
    return AppTextFormField(
      formKey: formKey,
      onTap: onTap,
      isPrice: isPrice,
      icon: icon,
      onlyNumbers: onlyNumbers,
      inputDecorationTheme: Theme.of(context).largeTextFieldDecoration(context),
      hint: hint,
      style: Theme.of(context).appTextFieldMediumTextStyle.copyWith(
        color: ScreenSizeService.isDesktop(context) ? AppColors.black : null,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      padding: padding,
      onChanged: onChanged,
      readOnly: readOnly,
    );
  }

  @override
  // ignore: library_private_types_in_public_api
  _AppTextFormFieldState createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.label != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.label!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    widget.required
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              "*",
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: AppColors.red),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              )
            : const SizedBox.shrink(),
        Form(
          key: widget.formKey,
          child: Padding(
            padding:
                widget.padding ?? const EdgeInsets.only(bottom: 10, top: 6),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(inputDecorationTheme: widget.inputDecorationTheme),
              child: Directionality(
                textDirection:
                    widget.textDirection ?? Directionality.of(context),
                child: TextFormField(
                  inputFormatters: widget.onlyNumbers
                      ? [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9\u0660-\u0669a-zA-Z\u0600-\u06FF]'),
                          ),
                        ]
                      : null,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  onTap: widget.onTap,
                  maxLength: widget.maxLength,
                  onChanged: (value) {
                    widget.formKey.currentState!.validate();
                    if (widget.isPrice) {
                      final formatted = _formatNumber(priceValue);
                      if (widget.controller?.text != formatted) {
                        widget.controller
                          ?..text = formatted
                          ..selection = TextSelection.collapsed(
                            offset: formatted.length,
                          );
                      }
                    }

                    if (widget.onChanged != null) widget.onChanged!(value);
                  },
                  style:
                      widget.style ??
                      Theme.of(context).appTextFieldSmallTextStyle,
                  readOnly: widget.readOnly,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  controller: widget.controller,
                  validator: widget.validator,
                  decoration: InputDecoration(
                    contentPadding: widget.contentPadding,
                    hintText: widget.hint,
                    prefixIcon: widget.prefixIcon,
                    suffixIcon:
                        widget.icon ??
                        ((widget.isPass
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hide = !_hide;
                                  });
                                },
                                icon: _hide
                                    ? Icon(
                                        Icons.visibility_off,
                                        size: Theme.of(context).iconTheme.size,
                                      )
                                    : Icon(
                                        Icons.visibility,
                                        size: Theme.of(context).iconTheme.size,
                                      ),
                              )
                            : null)),
                    isDense: true,
                  ),
                  obscureText: widget.isPass && _hide,
                  keyboardType: widget.keyboardType,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get priceValue => widget.controller?.text.replaceAll(",", '') ?? "";
  final intl.NumberFormat formatter = intl.NumberFormat("#,###,###,###.##");
  String _formatNumber(String input) {
    if (input.isEmpty) return '';
    if (input.contains('.')) {
      final beforeComma = num.parse(input.split('.').first);
      final afterComma = input.split('.').last;
      return "${formatter.format(beforeComma)}.$afterComma";
    } else {
      final number = num.parse(input);
      return formatter.format(number);
    }
  }
}
