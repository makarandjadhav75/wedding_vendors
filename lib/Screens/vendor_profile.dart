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

      if (resp.success && resp.data != null) {
        dynamic data = resp.data;

        // If API wraps in { "data": {...} }
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          data = data['data'];
        }

        // Normalize profile payload:
        // - Some APIs put user+vendor under keys { user: {...}, vendor: {...} }
        // - Some put everything at root
        Map<String, dynamic> normalized = {};
        if (data is Map<String, dynamic>) {
          if (data.containsKey('user') || data.containsKey('vendor')) {
            final user = (data['user'] is Map<String, dynamic>) ? data['user'] as Map<String, dynamic> : <String, dynamic>{};
            final vendor = (data['vendor'] is Map<String, dynamic>) ? data['vendor'] as Map<String, dynamic> : <String, dynamic>{};
            normalized = {...user, if (vendor.isNotEmpty) 'vendor': vendor};
          } else {
            normalized = data;
          }
        }

        setState(() {
          _profile = normalized;
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
          : _error != null
          ? Center(child: Text(_error!))
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

    // Extract vendor map from profile (supports either nested 'vendor' or flat keys)
    Map<String, dynamic> _vendorFromProfile(Map<String, dynamic> source) {
      final v = (source['vendor'] is Map<String, dynamic>)
          ? source['vendor'] as Map<String, dynamic>
          : source;
      return {
        'vendorId': v['vendorId'],
        'businessName': v['businessName'],
        'legalName': v['legalName'],
        'gstNumber': v['gstNumber'],
        'description': v['description'],
        'primaryCategoryId': v['primaryCategoryId'],
        'primaryCategoryName': v['primaryCategoryName'],
        'ratingAvg': v['ratingAvg'],
        'verified': v['verified'],
        'cityId': v['cityId'],
        'cityName': v['cityName'],
      };
    }

    final vendor = _vendorFromProfile(p);
    final hasVendor = [
      vendor['vendorId'],
      vendor['businessName'],
      vendor['primaryCategoryId'],
      vendor['cityId'],
    ].any((e) => e != null && e.toString().isNotEmpty);

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
                    Text(
                      name.isEmpty ? 'Vendor' : name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(email.isEmpty ? 'No email' : email),
                    if (role.isNotEmpty)
                      Text(role, style: const TextStyle(color: Colors.black54)),
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
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Full name'),
                  subtitle: Text(name.isEmpty ? '-' : name),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(email.isEmpty ? '-' : email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Role'),
                  subtitle: Text(role.isEmpty ? '-' : role),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text('Vendor details', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          if (hasVendor)
            Card(
              child: Column(
                children: [
                  if (vendor['vendorId'] != null)
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: const Text('Vendor ID'),
                      subtitle: Text('${vendor['vendorId']}'),
                    ),
                  if (vendor['businessName'] != null) const Divider(height: 1),
                  if (vendor['businessName'] != null)
                    ListTile(
                      leading: const Icon(Icons.storefront),
                      title: const Text('Business name'),
                      subtitle: Text('${vendor['businessName'] ?? '-'}'),
                    ),
                  if (vendor['legalName'] != null) const Divider(height: 1),
                  if (vendor['legalName'] != null)
                    ListTile(
                      leading: const Icon(Icons.gavel),
                      title: const Text('Legal name'),
                      subtitle: Text('${vendor['legalName'] ?? '-'}'),
                    ),
                  if (vendor['gstNumber'] != null) const Divider(height: 1),
                  if (vendor['gstNumber'] != null)
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: const Text('GST number'),
                      subtitle: Text('${vendor['gstNumber'] ?? '-'}'),
                    ),
                  if (vendor['primaryCategoryName'] != null) const Divider(height: 1),
                  if (vendor['primaryCategoryName'] != null)
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Primary category'),
                      subtitle: Text('${vendor['primaryCategoryName'] ?? '-'}'),
                    ),
                  if (vendor['ratingAvg'] != null) const Divider(height: 1),
                  if (vendor['ratingAvg'] != null)
                    ListTile(
                      leading: const Icon(Icons.star_rate_rounded),
                      title: const Text('Rating'),
                      subtitle: Text('${vendor['ratingAvg'] ?? '-'}'),
                    ),
                  if (vendor['verified'] != null) const Divider(height: 1),
                  if (vendor['verified'] != null)
                    ListTile(
                      leading: const Icon(Icons.verified),
                      title: const Text('Verified'),
                      subtitle: Text('${vendor['verified'] == true ? 'Yes' : 'No'}'),
                    ),
                  if (vendor['cityName'] != null) const Divider(height: 1),
                  if (vendor['cityName'] != null)
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: const Text('City'),
                      subtitle: Text('${vendor['cityName'] ?? '-'}'),
                    ),
                  if (vendor['description'] != null) const Divider(height: 1),
                  if (vendor['description'] != null)
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Description'),
                      subtitle: Text('${vendor['description'] ?? '-'}'),
                    ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No vendor information found for this account.',
                style: TextStyle(color: Colors.redAccent),
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