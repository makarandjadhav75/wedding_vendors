import 'package:flutter/material.dart';
import '../APiServices/api_services.dart';
import 'login_page.dart';
import 'vendor_login_page.dart';

class RoleSelectionScreen extends StatelessWidget {
  final ApiService apiService;
  const RoleSelectionScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      appBar: AppBar(
        title: const Text('Welcome'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose your path', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: 'User',
                        subtitle: 'Explore and plan your wedding',
                        icon: Icons.person_outline,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => LoginPage(apiService: apiService)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        title: 'Vendor',
                        subtitle: 'Offer your services to couples',
                        icon: Icons.store_mall_directory_outlined,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => VendorLoginPage(apiService: apiService)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _RoleCard({Key? key, required this.title, required this.subtitle, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.pinkAccent.withOpacity(.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: const Color(0xFFD6336C)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            const Text('Continue →', style: TextStyle(color: Colors.pink)),
          ],
        ),
      ),
    );
  }
}
