import 'package:anestrack_mobile/core/core_components/show_snack_bar.dart';
import 'package:anestrack_mobile/core/enum/user_type.dart';
import 'package:anestrack_mobile/core/network/exeptions/failure.dart';
import 'package:anestrack_mobile/core/utils/app_validator.dart';
import 'package:anestrack_mobile/core/utils/base_state.dart';
import 'package:anestrack_mobile/modules/auth/presentation/widgets/login_widgets.dart';
import 'package:anestrack_mobile/modules/student/home/presentation/routes/student_home_route.dart';
import 'package:anestrack_mobile/modules/supervisor/home/presentation/routes/supervisor_home_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../domain/entity/login_response.dart';
import '../blocs/login_bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  /// This screen is fully Responsive
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginBloc>(),
      child: BlocConsumer<LoginBloc, BaseState<LoginResponse>>(
        listener: _loginListener,
        builder: (context, state) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        children: [
                          const LoginLogoSection(),
                          const SizedBox(height: 32),
                          LoginCardContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.isError) ...[
                                  LoginErrorBanner(
                                    message: state.failure.message,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                LoginLabeledField(
                                  label: 'login.username'.tr(context: context),
                                  hint: '',
                                  icon: LucideIcons.mail,
                                  controller: _emailController,
                                  formKey: emailFormKey,
                                  validator: AppValidator().freeNameValidator,
                                ),
                                const SizedBox(height: 16),
                                LoginLabeledField(
                                  label: 'login.password'.tr(context: context),
                                  hint: '',
                                  icon: LucideIcons.lock,
                                  controller: _passwordController,
                                  formKey: passwordFormKey,
                                  validator: _passwordValidator,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 8),
                                // const LoginRememberForgotRow(),
                                const SizedBox(height: 16),
                                LoginSubmitButton(
                                  isLoading: state.isLoading,
                                  onPressed: () =>
                                      _loginPressed(context, state),
                                ),
                                const SizedBox(height: 16),
                                const LoginFooter(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'AnesTrack v1.0.0 © 2026',
                            style: TextStyle(
                              color: Color(0xFFCFFAFE),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _loginPressed(BuildContext context, BaseState<LoginResponse> state) {
    if (_checkInvalid(state)) return;
    context.read<LoginBloc>().add(
      LoginButtonTappedEvent(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  bool _checkInvalid(BaseState<LoginResponse> state) =>
      !AppValidator().checkValidateFormsKeys(
        forms: [emailFormKey, passwordFormKey],
        successCases: [!state.isLoading],
      );

  void _loginListener(BuildContext context, BaseState<LoginResponse> state) {
    if (state.isSuccess && state.data != null) {
      final userType = _resolveUserType(state.data!);
      if (userType == null) {
        showSnackBar(
          context,
          failure: const Failure('Unknown user type'),
          checkFailureType: false,
        );
        return;
      }

      showSnackBar(
        context,
        successMessage: LocaleKeys.loginDone.tr(context: context),
      );

      context.go(_routeForUserType(userType));
    }
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.emptyField.tr(context: context);
    }
    return null;
  }

  UserType? _resolveUserType(LoginResponse response) {
    final rawType = response.user.userType.isNotEmpty
        ? response.user.userType
        : response.type;
    final normalized = rawType.trim().toLowerCase();

    if (normalized == 'student') {
      return UserType.student;
    }
    if (normalized == 'supervisor' || normalized == 'superviser') {
      return UserType.supervisor;
    }
    return null;
  }

  String _routeForUserType(UserType userType) {
    switch (userType) {
      case UserType.student:
        return StudentHomeRoute.name;
      case UserType.supervisor:
        return SupervisorHomeRoute.name;
    }
  }
}
