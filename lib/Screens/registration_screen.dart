// lib/screens/create_account_page.dart
import 'package:flutter/material.dart';
import '../APiServices/api_services.dart';
import '../APiServices/common_repo.dart';
import 'vendor_onboarding_screen.dart';

class RegistrationScreen extends StatefulWidget {
  /// Required ApiService to perform registration.
  final ApiService apiService;

  /// Optional callback to receive submitted values (still pops values as well).
  final void Function(Map<String, String> values)? onSubmit;

  const RegistrationScreen({Key? key, required this.apiService, this.onSubmit}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _fullnameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _selectedRole;
  String? _emailError;
  String? _fullnameError;
  String? _passwordError;

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  final List<String> _roles = ['Vendor', 'Admin'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _fullnameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter email';
    final email = v.trim();
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter full name';
    if (v.trim().length < 2) return 'Name too short';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Please enter password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _roleValidator(String? v) {
    if (v == null || v.isEmpty) return 'Please choose a role';
    return null;
  }

  Future<void> _handleSubmit() async {
    // clear UI errors
    setState(() {
      _emailError = null;
      _fullnameError = null;
      _passwordError = null;
    });

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      'email': _emailCtrl.text.trim(),
      'fullName': _fullnameCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'role': _selectedRole!.toUpperCase(),
    };

    try {
      // call register API
      final CommonResponse<dynamic> resp = await widget.apiService.register(
        email: payload['email']!,
        fullName: payload['fullName']!,
        password: payload['password']!,
        role: payload['role']!,
      );

      // If backend indicates success
      if (resp.success) {
        if (!mounted) return;

        // call optional callback
        if (widget.onSubmit != null) {
          try {
            widget.onSubmit!(Map<String, String>.from({
              'email': payload['email']!,
              'fullname': payload['fullName']!,
              'role': payload['role']!,
            }));
          } catch (_) {}
        }

        // If user is Vendor, take them to onboarding to fill business details.
        if (payload['role'] == 'VENDOR') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Continue with vendor onboarding')));
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VendorOnboardingScreen(
                vendor: null,
                apiService: widget.apiService,
              ),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message.isNotEmpty ? resp.message : 'Registered successfully')));
        Navigator.of(context).pop({
          'email': payload['email']!,
          'fullname': payload['fullName']!,
          'role': payload['role']!,
        });
        return;
      }

      // Not success — show validation errors if present
      if (resp.errors != null && resp.errors!.isNotEmpty) {
        // Map server error keys (case-insensitive) into our fields
        final errors = <String, String>{};
        resp.errors!.forEach((k, v) => errors[k.toLowerCase()] = v);

        setState(() {
          _emailError = errors['email'] ?? errors['e-mail'] ?? errors['emailaddress'];
          _fullnameError = errors['fullname'] ?? errors['fullName'.toLowerCase()] ?? errors['name'];
          _passwordError = errors['password'];
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message.isNotEmpty ? resp.message : 'Registration failed')));
      }
    } catch (e, st) {
      debugPrint('Register error: $e\n$st');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxCardWidth = width > 700 ? 700.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: Column(
                children: [
                  // Decorative header
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF1F3), Color(0xFFFFF7F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.people_alt_rounded, size: 42, color: Color(0xFFD6336C)),
                          SizedBox(height: 8),
                          Text('Join WedMatch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Create your account to start planning', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Card with form
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Full name
                            TextFormField(
                              controller: _fullnameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Full name',
                                errorText: _fullnameError,
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: _nameValidator,
                            ),
                            const SizedBox(height: 12),

                            // Email
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                errorText: _emailError,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: _emailValidator,
                            ),
                            const SizedBox(height: 12),

                            // Password
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                errorText: _passwordError,
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: _passwordValidator,
                            ),
                            const SizedBox(height: 12),

                            // Role dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                              decoration: InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.badge_outlined),
                              ),
                              onChanged: (v) => setState(() => _selectedRole = v),
                              validator: _roleValidator,
                            ),

                            const SizedBox(height: 18),

                            // Submit
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Create account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Small footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account?'),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Sign in'),
                                )
                              ],
                            ),
                          ],
                        ),
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
}
