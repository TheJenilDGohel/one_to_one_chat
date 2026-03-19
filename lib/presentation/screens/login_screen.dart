import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../redux/actions.dart';
import '../../redux/app_state.dart';
import '../blocs/login_bloc.dart';
import 'user_list_screen.dart';
import '../../injection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late LoginBloc _bloc;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _bloc = LoginBloc(sl());

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _nameController.addListener(() => _bloc.changeName(_nameController.text));
    _emailController.addListener(
      () => _bloc.changeEmail(_emailController.text),
    );
    _passwordController.addListener(
      () => _bloc.changePassword(_passwordController.text),
    );

    _bloc.loginSuccess.listen((user) {
      if (!mounted) return;
      StoreProvider.of<AppState>(context).dispatch(SetUserAction(user));
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const UserListScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });

    _bloc.error.listen((msg) {
      if (!mounted || msg.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bloc.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: StreamBuilder<AuthMode>(
                    stream: _bloc.mode,
                    initialData: AuthMode.login,
                    builder: (context, modeSnap) {
                      final isRegister = modeSnap.data == AuthMode.register;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Logo ──────────────────────────────────────
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Headline ───────────────────────────────────
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              isRegister ? 'Create Account' : 'Welcome Back 👋',
                              key: ValueKey(isRegister),
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isRegister
                                ? 'Sign up to start chatting securely.'
                                : 'Sign in to continue your conversations.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.subtle,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // ── Card ───────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name field (register only)
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: SizedBox(
                                    height: isRegister ? null : 0,
                                    child: isRegister
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _fieldLabel('Your name'),
                                              const SizedBox(height: 8),
                                              TextField(
                                                controller: _nameController,
                                                style: GoogleFonts.inter(
                                                  color: AppTheme.onSurface,
                                                  fontSize: 15,
                                                ),
                                                textInputAction:
                                                    TextInputAction.next,
                                                decoration: const InputDecoration(
                                                  hintText: 'e.g. Jenil',
                                                  prefixIcon: Icon(
                                                    Icons
                                                        .person_outline_rounded,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),

                                // Email
                                _fieldLabel('Email'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  style: GoogleFonts.inter(
                                    color: AppTheme.onSurface,
                                    fontSize: 15,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'you@example.com',
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Password
                                _fieldLabel('Password'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  style: GoogleFonts.inter(
                                    color: AppTheme.onSurface,
                                    fontSize: 15,
                                  ),
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _bloc.submit(),
                                  decoration: InputDecoration(
                                    hintText: 'Min. 6 characters',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: AppTheme.subtle,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Submit button
                                StreamBuilder<bool>(
                                  stream: _bloc.isLoading,
                                  initialData: false,
                                  builder: (context, snap) {
                                    final loading = snap.data == true;
                                    return GestureDetector(
                                      onTap: loading ? null : _bloc.submit,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: double.infinity,
                                        height: 54,
                                        decoration: BoxDecoration(
                                          gradient: loading
                                              ? null
                                              : AppTheme.primaryGradient,
                                          color: loading
                                              ? AppTheme.surfaceVariant
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          boxShadow: loading
                                              ? null
                                              : [
                                                  BoxShadow(
                                                    color: AppTheme.primary
                                                        .withValues(
                                                          alpha: 0.35,
                                                        ),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                        ),
                                        child: Center(
                                          child: loading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color: AppTheme.primary,
                                                      ),
                                                )
                                              : Text(
                                                  isRegister
                                                      ? 'Create Account'
                                                      : 'Sign In',
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Mode toggle ────────────────────────────────
                          GestureDetector(
                            onTap: _bloc.toggleMode,
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.subtle,
                                ),
                                children: [
                                  TextSpan(
                                    text: isRegister
                                        ? 'Already have an account? '
                                        : "Don't have an account? ",
                                  ),
                                  TextSpan(
                                    text: isRegister ? 'Sign In' : 'Register',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.subtle,
      ),
    );
  }
}
