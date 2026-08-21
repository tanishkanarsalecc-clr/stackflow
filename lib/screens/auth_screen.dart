import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool loginMode = true;
  bool obscurePassword = true;
  bool checkingSession = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkExistingUser();
    });
  }

  // ============================================================
  // CHECK FIREBASE SESSION
  // ============================================================
  //
  // IMPORTANT:
  // We intentionally DO NOT navigate to Dashboard here.
  //
  // Firebase may remember a previously logged-in user.
  // However, for this app we want the Login screen to appear
  // whenever the application starts.
  //
  // Login/Register will still navigate to Dashboard normally.
  // ============================================================

  Future<void> _checkExistingUser() async {
    try {
      // Read the current Firebase user only to make sure Firebase
      // is available. We do not use it for automatic navigation.
      final User? user = FirebaseAuth.instance.currentUser;

      debugPrint(
        user == null
            ? 'No Firebase session found.'
            : 'Firebase session found, but showing Login screen.',
      );

      if (!mounted) return;

      setState(() {
        checkingSession = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Auth session check error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        checkingSession = false;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // SUBMIT LOGIN / REGISTER
  // ============================================================

  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    final String email = emailController.text.trim();
    final String password = passwordController.text;

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must be at least 6 characters.',
      );
      return;
    }

    // ------------------------------------------------------------
    // AUTH PROVIDER
    // ------------------------------------------------------------

    final app_auth.AuthProvider provider =
    context.read<app_auth.AuthProvider>();

    bool success = false;

    try {
      success = loginMode
          ? await provider.login(
        email,
        password,
      )
          : await provider.register(
        email,
        password,
      );
    } catch (e, stackTrace) {
      debugPrint('Authentication error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );

      return;
    }

    if (!mounted) return;

    // ------------------------------------------------------------
    // LOGIN / REGISTER SUCCESS
    // ------------------------------------------------------------

    if (success) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.dashboard,
      );
    }

    // ------------------------------------------------------------
    // AUTH ERROR
    // ------------------------------------------------------------

    else if (provider.error != null) {
      _showMessage(
        provider.error!,
      );
    }

    // ------------------------------------------------------------
    // UNKNOWN FAILURE
    // ------------------------------------------------------------

    else {
      _showMessage(
        loginMode
            ? 'Login failed. Please try again.'
            : 'Account creation failed. Please try again.',
      );
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  // ============================================================
  // SWITCH LOGIN / REGISTER
  // ============================================================

  void _toggleMode() {
    if (!mounted) return;

    final app_auth.AuthProvider provider =
    context.read<app_auth.AuthProvider>();

    provider.clearError();

    setState(() {
      loginMode = !loginMode;
      passwordController.clear();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------
    // FIREBASE SESSION CHECK
    // ------------------------------------------------------------

    if (checkingSession) {
      return const Scaffold(
        backgroundColor: Color(0xFF083E70),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // ------------------------------------------------------------
    // AUTH PROVIDER
    // ------------------------------------------------------------

    final app_auth.AuthProvider auth =
    context.watch<app_auth.AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF083E70),
              Color(0xFF087E9A),
              Color(0xFF08AFA5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: Column(
              children: [
                const SizedBox(height: 18),

                // =================================================
                // LOGO
                // =================================================

                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.20,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.layers_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // APP NAME
                // =================================================

                const Text(
                  'StackFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Inventory & Billing System',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // FEATURES
                // =================================================

                const _Feature(
                  icon: Icons.inventory_2_outlined,
                  text: 'Smart Inventory',
                ),

                const _Feature(
                  icon: Icons.receipt_long_outlined,
                  text: 'Seamless Billing',
                ),

                const _Feature(
                  icon: Icons.business_outlined,
                  text: 'Better Business',
                ),

                const SizedBox(height: 28),

                // =================================================
                // AUTH CARD
                // =================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(21),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ------------------------------------------------
                      // TITLE
                      // ------------------------------------------------

                      Text(
                        loginMode
                            ? 'Welcome Back'
                            : 'Create Account',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: StackFlowColors.text,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        loginMode
                            ? 'Sign in to continue to StackFlow'
                            : 'Create your StackFlow account',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color:
                          StackFlowColors.secondaryText,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ------------------------------------------------
                      // EMAIL
                      // ------------------------------------------------

                      AppTextField(
                        controller: emailController,
                        hint: 'Enter email',
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType:
                        TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 14),

                      // ------------------------------------------------
                      // PASSWORD
                      // ------------------------------------------------

                      Stack(
                        children: [
                          AppTextField(
                            controller: passwordController,
                            hint: 'Enter password',
                            label: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: obscurePassword,
                          ),

                          // =================================================
                          // PASSWORD EYE
                          // Slightly lower and centered vertically.
                          // =================================================

                          Positioned(
                            right: 7,
                            top: 11,
                            bottom: 3,
                            child: IconButton(
                              tooltip: obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: auth.loading
                                  ? null
                                  : () {
                                if (!mounted) return;

                                setState(() {
                                  obscurePassword =
                                  !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: StackFlowColors
                                    .secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // BUTTON
                      // ------------------------------------------------

                      AppButton(
                        text: loginMode
                            ? 'Login'
                            : 'Create Account',
                        loading: auth.loading,
                        onPressed: auth.loading
                            ? null
                            : submit,
                      ),

                      const SizedBox(height: 8),

                      // ------------------------------------------------
                      // SWITCH LOGIN / REGISTER
                      // ------------------------------------------------

                      TextButton(
                        onPressed: auth.loading
                            ? null
                            : _toggleMode,
                        child: Text(
                          loginMode
                              ? 'Create a new account'
                              : 'Already have an account? Login',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // SECURITY
                // =================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Colors.white.withValues(
                        alpha: 0.75,
                      ),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Your account is secured with Firebase',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.75,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// FEATURE ITEM
// ================================================================

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Feature({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 11),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}