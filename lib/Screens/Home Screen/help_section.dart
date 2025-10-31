// lib/screens/home/components/contact_quick_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactQuickForm extends StatefulWidget {
  final List<String> cities;
  final List<String> categories;

  const ContactQuickForm({
    Key? key,
    this.cities = const ['Mumbai', 'Delhi', 'Bengaluru', 'Chennai'],
    this.categories = const ['Catering', 'Photography', 'Decor', 'Makeup'],
  }) : super(key: key);

  @override
  State<ContactQuickForm> createState() => _ContactQuickFormState();
}

class _ContactQuickFormState extends State<ContactQuickForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  String? _selectedCity;
  String? _selectedCategory;
  bool _loading = false;

  // Replace with your target WhatsApp number (E.164) — user asked for 8956463580
  static const String _targetWhatsAppNumber = '+918956463580';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select city and vendor category')),
      );
      return;
    }

    setState(() => _loading = true);

    final phone = _phoneCtrl.text.trim();
    final city = _selectedCity!;
    final category = _selectedCategory!;
    final message = '📞 New Vendor Inquiry\n\n'
        'Phone: $phone\n'
        'City: $city\n'
        'Category: $category\n\n'
        'Please assist this user.';

    try {
      await _openWhatsAppWithFallback(phoneTo: _targetWhatsAppNumber, message: message);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opened WhatsApp / share sheet.')));
      _formKey.currentState!.reset();
      _phoneCtrl.clear();
      setState(() {
        _selectedCity = null;
        _selectedCategory = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openWhatsAppWithFallback({
    required String phoneTo, // E.164, e.g. +918956463580
    required String message,
  }) async {
    final plain = phoneTo.replaceAll('+', '').replaceAll(RegExp(r'\s+'), '');
    final encoded = Uri.encodeComponent(message);

    // 1) WhatsApp app deep link
    final uriApp = Uri.parse('whatsapp://send?phone=$plain&text=$encoded');
    try {
      if (await canLaunchUrl(uriApp)) {
        final launched = await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        if (launched) return;
      }
    } catch (_) {
      // ignore and continue to fallback
    }

    // 2) wa.me web link
    final uriWeb = Uri.parse('https://wa.me/$plain?text=$encoded');
    try {
      if (await canLaunchUrl(uriWeb)) {
        final launched = await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
        if (launched) return;
      }
    } catch (_) {
      // ignore and continue
    }

    // 3) Share sheet fallback
    try {
      await Share.share(message, subject: 'Vendor inquiry');
      return;
    } catch (_) {
      // ignore and continue
    }

    // 4) SMS fallback
    try {
      final smsUri = Uri(scheme: 'sms', path: plain, queryParameters: {'body': message});
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return;
      }
    } catch (_) {
      // ignore
    }

    throw 'Unable to open WhatsApp, web or share sheet on this device.';
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.pink.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF6F7),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Help us with your details',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our executives will call you to understand your requirements to find suitable vendors',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              final phoneField = TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Enter mobile number'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Enter mobile number';
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(t)) {
                    return 'Enter valid 10-digit number';
                  }
                  return null;
                },
              );

              final cityField = DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: _inputDecoration('Select city'),
                items: widget.cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCity = v),
                validator: (v) => v == null ? 'Select city' : null,
              );

              final categoryField = DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration('Select vendor category'),
                items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Select category' : null,
              );

              final submitButton = SizedBox(
                width: isWide ? 170 : double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5370),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text(
                    'Submit via WhatsApp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: phoneField),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: cityField),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: categoryField),
                    const SizedBox(width: 16),
                    SizedBox(width: 170, child: submitButton),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    phoneField,
                    const SizedBox(height: 12),
                    cityField,
                    const SizedBox(height: 12),
                    categoryField,
                    const SizedBox(height: 12),
                    submitButton,
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
