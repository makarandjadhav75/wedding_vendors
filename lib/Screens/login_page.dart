// lib/screens/wedding_login_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../APiServices/api_services.dart';
import 'admin_screen.dart';
import 'Home Screen/home_screen.dart';
import 'registration_screen.dart';

class LoginPage extends StatefulWidget {
  final ApiService apiService;

  const LoginPage({Key? key, required this.apiService}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  late AnimationController _animController;
  late Animation<double> _fadeInAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeInAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _extractRoleFromJwt(String token) {
    try {
      // JWT expected: header.payload.signature
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];

      // Base64Url decode with proper padding
      String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      final decoded = utf8.decode(
          base64Url.decode(payload)); // use base64Url.decode directly
      final Map<String, dynamic> map = jsonDecode(decoded) as Map<
          String,
          dynamic>;

      // common claim names to check
      final possible = <String>[
        'role',
        'roles',
        'authority',
        'authorities',
        'scope'
      ];
      for (final key in possible) {
        if (map.containsKey(key) && map[key] != null) {
          final val = map[key];
          if (val is String) return val;
          if (val is List && val.isNotEmpty) return val.first.toString();
          if (val is Map) return val.values.join(',');
          return val.toString();
        }
      }

      // maybe role is inside 'user' or 'data'
      if (map.containsKey('user') && map['user'] is Map) {
        final u = map['user'] as Map<String, dynamic>;
        if (u.containsKey('role')) return u['role']?.toString();
      }

      return null;
    } catch (e) {
      print('JWT decode failed: $e');
      return null;
    }
  }



  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        if (email.isEmpty) _emailError = 'Please enter email';
        if (password.isEmpty) _passwordError = 'Please enter password';
      });
      return;
    }

    try {
      final resp = await widget.apiService.login(email: email, password: password);
      print('[UI] login response success=${resp.success} message=${resp.message}');

      if (resp.success && resp.data != null) {
        final model = resp.data!;
        // store token securely
        await _storage.write(key: 'auth_token', value: model.token);
        await _storage.write(key: 'expires_at', value: model.expiresAt.toString());

        // === determine role ===
        String role = '';

        // 1) If response data contains role field (optional)
        try {
          // If your CommonResponse keeps the raw JSON somewhere (or your LoginModel
          // has a role property), use that. For safety we check json-like map.
          // If LoginModel had role property: role = model.role ?? '';
          // Otherwise attempt to read resp.raw? (skip if not available)
        } catch (_) {}

        // 2) Try decode JWT token claims to extract role
        if (role.isEmpty && model.token.isNotEmpty) {
          role = _extractRoleFromJwt(model.token) ?? '';
        }

        // 3) Fallback: ask backend for profile (optional)
        if (role.isEmpty) {
          try {
            final profileResp = await widget.apiService.getProfile(); // implement below
            if (profileResp.success && profileResp.data is Map<String, dynamic>) {
              final Map<String, dynamic> profile = profileResp.data as Map<String, dynamic>;
              role = (profile['role'] ?? profile['roles'] ?? profile['authority'])?.toString() ?? '';
            }
          } catch (e) {
            // ignore, role will remain empty
          }
        }

        // normalize role to simple value for checking
        final roleNormalized = role.toLowerCase();

        // navigate based on role
        if (!mounted) return;
        if (roleNormalized.contains('admin')) {
          // go to admin page
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminScreen()));
        } else if (roleNormalized.contains('vendor')) {
          // go to categories screen (pass your ApiService)
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(apiService: widget.apiService)));
        } else {
          // unknown role — fallback to home / categories
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(apiService: widget.apiService)));
        }

      } else {
        // show validation errors and messages as before
        if (resp.errors != null && resp.errors!.isNotEmpty) {
          setState(() {
            _emailError = resp.errors!['email'];
            _passwordError = resp.errors!['password'];
          });
        }
        final message = resp.message.isNotEmpty ? resp.message : 'Login failed';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (e, st) {
      print('❌ Exception in _submit: $e');
      print(st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Widget _buildTopDecoration(double width) {
    // simple floral-like decorative shapes using positioned circles & heart
    return SizedBox(
      height: 220,
      width: width,
      child: Stack(
        children: [
          // background gradient arc
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF1F3), Color(0xFFFFF7F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Heart icon
          Positioned(
            top: 68,
            left: (width / 2) - 36,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
              ),
              child: const Icon(Icons.favorite, color: Color(0xFFD6336C), size: 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardMaxWidth = screenW > 700 ? 600.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeInAnim,
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top decorative area
                      _buildTopDecoration(cardMaxWidth),
                      const SizedBox(height: 8),

                      // Card with form
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title + subtitle
                              Row(
                                children: [
                                  // small logo circle
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEEF2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.ring_volume, color: Color(0xFFD6336C)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Welcome to WedMatch',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 4),
                                        Text('Plan, Invite & Celebrate — sign in to continue',
                                            style: TextStyle(fontSize: 13, color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Form
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Email field
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'you@love.com',
                                        errorText: _emailError,
                                        prefixIcon: const Icon(Icons.email_outlined),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Please enter email';
                                        // simple email check
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val.trim())) return 'Enter a valid email';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Password
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        errorText: _passwordError,
                                        prefixIcon: const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Please enter password';
                                        if (val.length < 6) return 'Password must be at least 6 characters';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Login button (gradient)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _submit,
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                          elevation: MaterialStateProperty.all(6),
                                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                                            // keep gradient visual via Ink on Container below, but fallback color needed
                                            return Colors.pink;
                                          }),

                                        ),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFD6336C), Color(0xFFFF9AB3)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: _isLoading
                                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Forgot / Divider
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            // go to forgot password
                                          },
                                          child: const Text('Forgot password?'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final result = await Navigator.of(context).push<Map<String, String>>(
                                              MaterialPageRoute(
                                                builder: (_) => RegistrationScreen(
                                                  apiService: widget.apiService, // <-- pass widget.apiService
                                                ),
                                              ),
                                            );

                                            if (result != null) {
                                              setState(() {
                                                _emailController.text = result['email'] ?? '';
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Account created — please sign in')),
                                              );
                                            }
                                          },
                                          child: const Text('Create account'),
                                        ),


                                      ],
                                    ),

                                    const SizedBox(height: 6),
                                    Row(children: const [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text('or continue with', style: TextStyle(color: Colors.black45)),
                                      ),
                                      Expanded(child: Divider()),
                                    ]),
                                    const SizedBox(height: 10),

                                    // Social buttons row
                                    Row(
                                      children: [
                                        _buildSocialButton(icon: Icons.facebook, label: 'Facebook', onTap: () {}),
                                        const SizedBox(width: 10),
                                        _buildSocialButton(icon: Icons.g_mobiledata, label: 'Google', onTap: () {}),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Footer invitation
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          children: const [
                            Text('Make your special day unforgettable ✨', style: TextStyle(fontSize: 14, color: Colors.black87)),
                            SizedBox(height: 8),
                            Text('By signing in you agree to our Terms & Privacy', style: TextStyle(fontSize: 12, color: Colors.black45)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
