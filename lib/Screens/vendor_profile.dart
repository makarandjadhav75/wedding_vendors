import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../APiServices/api_services.dart';
import 'login_page.dart';

class VendorProfileScreen extends StatefulWidget {
  final ApiService apiService;
  const VendorProfileScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final _storage = const FlutterSecureStorage();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _profile;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      _token = token;
      if (token == null || token.isEmpty) {
        setState(() {
          _loading = false;
          _profile = null;
        });
        return;
      }

      final resp = await widget.apiService.getProfile();
      if (!mounted) return;
      if (resp.success && resp.data is Map<String, dynamic>) {
        setState(() {
          _profile = resp.data as Map<String, dynamic>;
          _loading = false;
        });
      } else {
        setState(() {
          _error = resp.message.isNotEmpty ? resp.message : 'Failed to load profile';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'expires_at');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage(apiService: widget.apiService)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_token != null && _token!.isNotEmpty)
            IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_token == null || _token!.isEmpty)
              ? _buildSignedOut()
              : _buildProfile(),
    );
  }

  Widget _buildSignedOut() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: Colors.pink),
            const SizedBox(height: 12),
            const Text('You are not signed in'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LoginPage(apiService: widget.apiService),
                  ),
                );
              },
              child: const Text('Sign in'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final p = _profile ?? {};
    final name = (p['fullName'] ?? p['name'] ?? '').toString();
    final email = (p['email'] ?? '').toString();
    final role = (p['role'] ?? p['roles'] ?? p['authority'] ?? '').toString();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? 'Vendor' : name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email.isEmpty ? 'No email' : email),
                    if (role.isNotEmpty) Text(role, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.badge), title: const Text('Full name'), subtitle: Text(name.isEmpty ? '-' : name)),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(email.isEmpty ? '-' : email)),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.verified_user), title: const Text('Role'), subtitle: Text(role.isEmpty ? '-' : role)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh profile'),
                  onTap: _load,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout'),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
