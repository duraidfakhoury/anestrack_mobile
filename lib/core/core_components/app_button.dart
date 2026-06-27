import 'package:anestrack_mobile/core/enum/app_button_type.dart';
import 'package:anestrack_mobile/core/extensions/app_button_theme.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height,
    this.width,
    this.buttonStyle,
    this.textStyle,
    this.margin,
    this.appButtonType = AppButtonType.normal,
    this.isLoading = false,
    this.icon,
    this.flexSize = false,
    this.toUpperCaseLabel = true,
    this.radius,
    this.child,
    this.isActive = true,
  });

  final String label;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  final AppButtonType appButtonType;

  final bool isLoading;

  // is active value only set to border type == normal
  final bool isActive;

  final Widget? icon;

  final bool flexSize;
  final bool toUpperCaseLabel;
  final Widget? child;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    var textWidget = FittedBox(
      child: Text(
        toUpperCaseLabel ? label.toUpperCase() : label,
        style: getAppButtonTextStyle(context),
      ),
    );
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ElevatedButton(
        onPressed: isActive ? onTap : null,
        style: getAppButtonStyle(context),
        child: Container(
          alignment: flexSize ? null : Alignment.center,
          width: flexSize ? null : width ?? double.infinity,
          height: flexSize ? null : height ?? 37,
          child:
              child ??
              (isLoading
                  ? LoadingAnimationWidget.inkDrop(
                      color:
                          getAppButtonTextStyle(context).color ??
                          AppColors.black,
                      size: Theme.of(context).iconTheme.size!,
                    )
                  : icon != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 30, child: Center(child: icon!)),
                        SizedBox(width: 1.w),
                        Expanded(child: textWidget),
                      ],
                    )
                  : textWidget),
        ),
      ),
    );
  }

  ButtonStyle getAppButtonStyle(BuildContext context) {
    if (buttonStyle != null) return buttonStyle!;
    switch (appButtonType) {
      case AppButtonType.normal:
        return Theme.of(
          context,
        ).normalAppButtonStyle(radius: radius, isActive: isActive);
      case AppButtonType.unFilled:
        return Theme.of(context).unFilledAppButtonStyle(radius: radius);
      case AppButtonType.redBorder:
        return Theme.of(context).redBorderAppButtonStyle(radius: radius);
      case AppButtonType.grey:
        return Theme.of(context).greyAppButtonStyle(radius: radius);
      case AppButtonType.red:
        return Theme.of(
          context,
        ).redAppButtonStyle(radius: radius, isActive: isActive);
    }
  }

  TextStyle getAppButtonTextStyle(BuildContext context) {
    if (textStyle != null) return textStyle!;
    switch (appButtonType) {
      case AppButtonType.normal:
        return Theme.of(context).textTheme.displayMedium!;
      case AppButtonType.unFilled:
        return Theme.of(context).textTheme.labelMedium!;

      case AppButtonType.redBorder:
        return Theme.of(context).textTheme.labelMedium!;
      case AppButtonType.grey:
        return Theme.of(
          context,
        ).textTheme.displayMedium!.copyWith(color: AppColors.white);
      case AppButtonType.red:
        return Theme.of(
          context,
        ).textTheme.displayMedium!.copyWith(color: AppColors.white);
    }
  }
}
