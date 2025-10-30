import 'package:flutter/material.dart';
import 'package:commercepal/core/theme/colors.dart';
import 'package:commercepal/core/constants/spacing.dart';
import 'package:commercepal/services/localization_service.dart';
import 'package:commercepal/features/auth/signup/presentation/widgets/signup_widgets.dart';
import 'package:commercepal/features/auth/login/presentation/widgets/login_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: Spacing.md),
              // Back button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(Spacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: Spacing.sm),
              // Title
              Text(
                LocalizationService.t(context, 'auth.signup.title'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              // Subtitle
              Text(
                LocalizationService.t(context, 'auth.signup.subtitle'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: Spacing.lg),
              // Full Name field
              FullNameInputField(controller: _fullNameController),
              const SizedBox(height: Spacing.md),
              // Email field
              SignupEmailInputField(controller: _emailController),
              const SizedBox(height: Spacing.md),
              // Date of birth field
              DateOfBirthInputField(controller: _dateOfBirthController),
              const SizedBox(height: Spacing.md),
              // Password field
              SignupPasswordInputField(controller: _passwordController),
              const SizedBox(height: Spacing.md),
              // Terms and Privacy Policy text
              TermsAndPolicyText(
                onTermsTap: () {
                  // TODO: Navigate to terms screen
                },
                onPrivacyTap: () {
                  // TODO: Navigate to privacy screen
                },
                onPolicyTap: () {
                  // TODO: Navigate to policy screen
                },
              ),
              const SizedBox(height: Spacing.lg),
              // Create Account button with arrow icon
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // TODO: Handle signup
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        LocalizationService.t(
                          context,
                          'auth.signup.createAccountButton',
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              // Or separator
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    child: Text(
                      LocalizationService.t(context, 'auth.signup.or'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl),
              // Social signup buttons
              SocialSignupButton(
                type: SocialLoginType.google,
                onPressed: () {
                  // TODO: Handle Google signup
                },
              ),
              const SizedBox(height: Spacing.md),
              SocialSignupButton(
                type: SocialLoginType.facebook,
                onPressed: () {
                  // TODO: Handle Facebook signup
                },
              ),
              const SizedBox(height: Spacing.md),
              SocialSignupButton(
                type: SocialLoginType.apple,
                onPressed: () {
                  // TODO: Handle Apple signup
                },
              ),
              const SizedBox(height: Spacing.xxl),
              // Login link
              LoginLink(
                onTap: () {
                  // TODO: Navigate to login screen
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Social signup button widget (adapted from SocialLoginButton)
class SocialSignupButton extends StatelessWidget {
  const SocialSignupButton({super.key, required this.type, this.onPressed});

  final SocialLoginType type;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Map<SocialLoginType, Map<String, dynamic>> buttonConfig = {
      SocialLoginType.google: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.signup.socialGoogle'),
        'backgroundColor': Colors.white,
        'textColor': Colors.black,
        'borderColor': Colors.grey[300]!,
        'imagePath': 'assets/images/Google.png',
      },
      SocialLoginType.facebook: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.signup.socialFacebook'),
        'backgroundColor': const Color(0xFF1877F2),
        'textColor': Colors.white,
        'borderColor': const Color(0xFF1877F2),
        'imagePath': 'assets/images/Facebook.png',
      },
      SocialLoginType.apple: <String, dynamic>{
        'label': LocalizationService.t(context, 'auth.signup.socialApple'),
        'backgroundColor': Colors.black,
        'textColor': Colors.white,
        'borderColor': Colors.black,
        'imagePath': 'assets/images/Apple.png',
      },
    };

    final Map<String, dynamic> config = buttonConfig[type]!;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: config['backgroundColor'] as Color,
          side: BorderSide(color: config['borderColor'] as Color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              config['imagePath'] as String,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              config['label'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: config['textColor'] as Color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

