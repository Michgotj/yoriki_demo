import 'package:animated_toast_list/animated_toast_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/change_language.dart';
import 'package:lightmachine/components/widgets/keyboard_closable.dart';
import 'package:lightmachine/components/widgets/loading_overlay.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/assets.dart';
import 'package:lightmachine/style/theme/theme_extension/ext.dart';
import 'package:lightmachine/toasts/toast_model.dart';

import '../../components/widgets/app_button.dart';
import '../../models/services/analytics_service.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  late MultiValidator passwordValidator;
  late MultiValidator emailValidator;

  @override
  void initState() {
    super.initState();
    passwordValidator = MultiValidator([
      RequiredValidator(errorText: 'Password is required'.tr),
      MinLengthValidator(8, errorText: 'Minimum 8 characters'.tr),
      //PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'passwords must have at least one special character')
    ]);
    emailValidator = MultiValidator([
      RequiredValidator(errorText: 'Field is required'.tr),
      EmailValidator(errorText: 'Enter a valid email address'.tr)
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputLightBg = context.appColors.inputLightBg;
    final inputLightBorder = context.appColors.inputLightBorder;
    final inputLightText = context.appColors.inputLightText;
    final inputDarkText = context.appColors.inputDarkText;

    final inputFont = context.appTextStyles.text?.copyWith(
      fontSize: 14.sp,
      color: inputDarkText,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.4,
    );

    final hintFont = context.appTextStyles.text?.copyWith(
      fontSize: 12.sp,
      color: inputLightText,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.4,
    );

    final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(
        color: inputLightBorder,
        width: 1,
        style: BorderStyle.solid,
      ),
    );

    final focusedBorder = enabledBorder.copyWith(
      borderSide: enabledBorder.borderSide.copyWith(width: 2),
    );

    final errorBorder = enabledBorder.copyWith(
      borderSide: enabledBorder.borderSide.copyWith(color: Colors.red),
    );

    final contentPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    InputDecoration inputDecoration(String hintText) {
      return InputDecoration(
        border: InputBorder.none,
        contentPadding: contentPadding,
        fillColor: inputLightBg,
        filled: true,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        errorMaxLines: 1,
        hintText: hintText,
        hintStyle: hintFont,
        hintMaxLines: 1,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: KeyboardClosable(
        child: Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textDirection: TextDirection.ltr,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                Assets.login_logo,
                                width: 190.w,
                                height: 198.h,
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 32.h),
                            child: TextButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              onPressed: _controller.switchFormAction,
                              child: Obx(
                                    () => _controller.isSignUp.value
                                    ? Text(
                                  'Log In'.tr,
                                  style: context.appTextStyles.button
                                      ?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.4,
                                    color: context.appColors.textWhite,
                                  ),
                                )
                                    : Text(
                                  'Sign Up'.tr,
                                  style: context.appTextStyles.button
                                      ?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.4,
                                    color: context.appColors.textWhite,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Obx(
                                        () => _controller.isSignUp.value
                                        ? Text(
                                      'Create your account'.tr,
                                      style: context.appTextStyles.text
                                          ?.copyWith(
                                        fontSize: 17.sp,
                                        color:
                                        context.appColors.textWhite,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.4,
                                      ),
                                    )
                                        : Text(
                                      'Sign In to your account'.tr,
                                      style: context.appTextStyles.text
                                          ?.copyWith(
                                        fontSize: 17.sp,
                                        color:
                                        context.appColors.textWhite,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                              // Name
                              Obx(() => _controller.isSignUp.value
                                  ? TextFormField(
                                keyboardType: TextInputType.name,
                                maxLines: 1,
                                decoration:
                                inputDecoration('Full Name'.tr),
                                style: inputFont,
                                validator: RequiredValidator(
                                    errorText:
                                    'This field is required'.tr),
                                onSaved: (value) {
                                  _controller.name = value?.trim() ?? '';
                                },
                              )
                                  : const SizedBox.shrink()),

                              Obx(() => _controller.isSignUp.value
                                  ? SizedBox(height: 27.h)
                                  : const SizedBox.shrink()),

                              // Email
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                maxLines: 1,
                                decoration: inputDecoration('Email address'.tr),
                                style: inputFont,
                                validator: emailValidator,
                                onSaved: (value) {
                                  _controller.email = value?.trim() ?? '';
                                },
                              ),
                              SizedBox(height: 27.h),

                              // Password
                              TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                maxLines: 1,
                                decoration:
                                inputDecoration('Minimum 8 characters'.tr),
                                style: inputFont,
                                validator: passwordValidator,
                                obscureText: true,
                                onSaved: (value) {
                                  _controller.password = value?.trim() ?? '';
                                },
                              ),
                              SizedBox(height: 15.h),
                              Text.rich(
                                style: context.appTextStyles.text?.copyWith(
                                  fontSize: 12.sp,
                                  color: context.appColors.textWhite,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.4,
                                ),
                                textAlign: TextAlign.center,
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'By signing up, you accept our '.tr,
                                    ),
                                    TextSpan(
                                      text: 'Terms and Conditions'.tr,
                                      style:
                                      context.appTextStyles.text?.copyWith(
                                        fontSize: 12.sp,
                                        color: AppColors.green,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.4,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = _onTapTerms,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 9.0.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(
                                          () => _controller.isSignUp.value
                                          ? AppButtonLight(
                                        title: 'Sign Up'.tr,
                                        onPressed: _onFormSubmit,
                                      )
                                          : AppButtonLight(
                                        title: 'Log In'.tr,
                                        onPressed: _onFormSubmit,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            height: 1.h,
                                            width: double.infinity,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 30.0.h),
                                          child: Text(
                                            'OR'.tr,
                                            style: context.appTextStyles.text
                                                ?.copyWith(
                                              fontSize: 13.5.sp,
                                              color:
                                              context.appColors.textWhite,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            height: 1.h,
                                            width: double.infinity,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    TextButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            side: const BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(13.r),
                                          ),
                                        ),
                                      ),
                                      onPressed: _onGoogleSignIn,
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              Assets.googleLogo,
                                              width: 15,
                                              height: 15,
                                            ),
                                            SizedBox(
                                              width: 13.w,
                                            ),
                                            Text(
                                              'Continue with Google'.tr,
                                              style: context
                                                  .appTextStyles.button
                                                  ?.copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: -0.4,
                                                color:
                                                context.appColors.textWhite,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0.w),
                        child: ChangeLanguage(),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                    () => _controller.isLoading.value
                    ? LoadingOverlay()
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGoogleSignIn() async {
    aService.logEvent(AEvents.onPressButtonLoginGoogle);
    if (_controller.isLoading.value) {
      return;
    }
    final result = await _controller.signInWithGoogle();
    if (result.isError) {
      _onError('Signing in was failed...'.tr);
      return;
    }
    _onSuccess(result.result ?? '');
  }

  Future<void> _onFormSubmit() async {
    final isValidInput = _formKey.currentState?.validate() ?? false;
    if (!isValidInput) {
      return;
    }
    _formKey.currentState?.save();
    final result = await _controller.submitForm();
    if (result.isError) {
      _onError(result.error ?? 'Action failed...');
      return;
    }
    _onSuccess(result.result ?? '');
  }

  void _onTapTerms() {
    // todo
  }

  void _onError(String message) {
    if (mounted) {
      context.showToast(
        MyToastModel(
          message,
          ToastType.failed,
        ),
      );
    }
  }

  void _onSuccess(String name) {
    if (mounted) {
      context.showToast(
        MyToastModel(
          '${'Welcome'.tr}, $name',
          ToastType.success,
        ),
      );
    }
    Get.toNamed('/');
  }
}
