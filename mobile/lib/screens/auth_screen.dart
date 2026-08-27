import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'main_screen.dart';

const _quickLoginEmail = 'testowy@gmail.com';
const _quickLoginPassword = 'oiLgEzz#h3MtYcoT';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  Future<void> _quickLogin() async {
    if (_quickLoginEmail.isEmpty || _quickLoginPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak skonfigurowanego konta testowego')),
      );
      return;
    }

    _emailController.text = _quickLoginEmail;
    _passwordController.text = _quickLoginPassword;
    await _submit();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        final response = await _authService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _displayNameController.text.trim(),
        );
        if (response.session == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sprawdź email i potwierdz konto przed logowaniem'),
            ),
          );
          return;
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    final error = AuthService.validateEmail(email);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    try {
      await _authService.resetPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jeśli konto istnieje, wysłaliśmy link resetujący'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nie udało się wysłać linku resetującego.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF704D);
    const background = Color(0xFFF2F2F2);
    const fieldRadius = BorderRadius.all(Radius.circular(8));

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/spontanlogo_register.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'NaSpontanie',
                    style: TextStyle(
                      color: Color(0xFF1B2A41),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Zaloguj się' : 'Zarejestruj się',
                    style: const TextStyle(
                      color: Color(0xFF1B2A41),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide(color: orange, width: 2),
                      ),
                    ),
                    validator: (v) => AuthService.validateEmail(v ?? ''),
                  ),
                  const SizedBox(height: 14),

                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Imię',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: fieldRadius,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: fieldRadius,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: fieldRadius,
                          borderSide: BorderSide(color: orange, width: 2),
                        ),
                      ),
                      validator: (v) =>
                          AuthService.validateDisplayName(v ?? ''),
                    ),
                    const SizedBox(height: 14),
                  ],

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Hasło',
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: BorderSide(color: orange, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (v) => AuthService.validatePassword(v ?? ''),
                  ),
                  const SizedBox(height: 12),

                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: const Text('Nie pamiętasz hasła?'),
                      ),
                    ),

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: fieldRadius,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isLogin ? 'Zaloguj się' : 'Zarejestruj się',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _quickLogin,
                        icon: const Icon(Icons.flash_on_outlined),
                        label: const Text('Szybkie logowanie'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1B2A41),
                          side: const BorderSide(color: Color(0xFF1B2A41)),
                          shape: const RoundedRectangleBorder(
                            borderRadius: fieldRadius,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Zarejestruj się' : 'Zaloguj się',
                      style: const TextStyle(
                        color: Color(0xFF1B2A41),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
}
