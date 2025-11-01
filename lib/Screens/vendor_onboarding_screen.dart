import 'package:flutter/material.dart';
import '../Models/page_data_Model.dart';
import '../Models/vendor_model.dart';
import '../APiServices/api_services.dart';
import '../Models/categery_model.dart';
import '../APiServices/common_repo.dart';
import 'vendor_profile.dart';

class VendorOnboardingScreen extends StatefulWidget {
  final Vendor? vendor;
  final ApiService apiService;

  const VendorOnboardingScreen({
    super.key,
    this.vendor,
    required this.apiService,
  });

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  late final TextEditingController _businessNameCtrl;
  late final TextEditingController _legalNameCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _descCtrl;

  List<Category> _categories = [];
  Category? _selectedCategory;

  final List<Map<String, dynamic>> _cities = const [
    {'id': 1, 'name': 'Mumbai'},
    {'id': 2, 'name': 'Delhi'},
    {'id': 3, 'name': 'Visakhapatnam'},
    {'id': 4, 'name': 'Bengaluru'},
  ];
  Map<String, dynamic>? _selectedCity;

  bool _loadingCats = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _businessNameCtrl = TextEditingController(text: widget.vendor?.businessName ?? '');
    _legalNameCtrl = TextEditingController(text: widget.vendor?.legalName ?? '');
    _gstCtrl = TextEditingController(text: widget.vendor?.gstNumber ?? '');
    _descCtrl = TextEditingController(text: widget.vendor?.description ?? '');

    if (widget.vendor != null) {
      _selectedCity = _cities.firstWhere(
        (c) => c['id'] == widget.vendor!.cityId,
        orElse: () => _cities.first,
      );
    } else {
      _selectedCity = _cities.first;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCats = true);
    try {
      final CommonResponse<PagedData<Category>> resp =
      await widget.apiService.getCategories(page: 0, size: 50);
      if (resp.success && resp.data != null) {
        final cats = resp.data!.content;
        setState(() {
          _categories = cats;
          if (cats.isEmpty) {
            _selectedCategory = null;
          } else if (widget.vendor != null) {
            _selectedCategory = cats.firstWhere(
              (c) => (c.id is int ? c.id as int : int.tryParse('${c.id}') ?? -1) == widget.vendor!.primaryCategoryId,
              orElse: () => cats.first,
            );
          } else {
            _selectedCategory = cats.first;
          }
        });
      }
    } catch (_) {
      // Ignore for now or log error
    } finally {
      if (mounted) setState(() => _loadingCats = false);
    }
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _legalNameCtrl.dispose();
    _gstCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vendor;

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Vendor Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pinkAccent.withOpacity(.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (v != null)
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.store)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          v.ownerFullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          v.verified ? 'Verified' : 'Unverified',
                          style: const TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                if (v != null) ...[
                  Text('Primary Category: ${v.primaryCategoryName} (#${v.primaryCategoryId})'),
                  Text('City: ${v.cityName} (#${v.cityId})'),
                ] else ...[
                  const Text('No vendor created yet. Please fill the details below.'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _businessNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Business name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _legalNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Legal name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _gstCtrl,
            decoration: const InputDecoration(
              labelText: 'GST number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ Category dropdown
          _loadingCats
              ? const Center(
              child:
              Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
              : DropdownButtonFormField<Category>(
            value: _selectedCategory,
            items: _categories
                .map((c) => DropdownMenuItem(
              value: c,
              child: Text(
                c.name?.toString().replaceAll('_', ' ') ??
                    'Category',
              ),
            ))
                .toList(),
            onChanged: (c) => setState(() => _selectedCategory = c),
            decoration: const InputDecoration(
              labelText: 'Primary category',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ City dropdown
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedCity,
            items: _cities
                .map((c) => DropdownMenuItem<Map<String, dynamic>>(
              value: c,
              child: Text(c['name'] as String),
            ))
                .toList(),
            onChanged: (c) => setState(() => _selectedCity = c),
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _submitting
                  ? null
                  : () async {
                      final businessName = _businessNameCtrl.text.trim();
                      final legalName = _legalNameCtrl.text.trim();
                      final gst = _gstCtrl.text.trim();
                      final desc = _descCtrl.text.trim();
                      final cityId = (_selectedCity?['id'] as int?) ?? 0;
                      final catId = (_selectedCategory?.id is int)
                          ? _selectedCategory!.id as int
                          : int.tryParse('${_selectedCategory?.id ?? 0}') ?? 0;

                      if (businessName.isEmpty || legalName.isEmpty || catId == 0 || cityId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill business name, legal name, category and city.')));
                        return;
                      }

                      setState(() => _submitting = true);

                      final isUpdating = v != null && (v.vendorId) != 0;
                      final resp = isUpdating
                          ? await widget.apiService.updateVendor(
                              vendorId: v!.vendorId,
                              businessName: businessName,
                              cityId: cityId,
                              primaryCategoryId: catId,
                              legalName: legalName,
                              gstNumber: gst,
                              description: desc,
                              ratingAvg: v.ratingAvg,
                              verified: v.verified,
                            )
                          : await widget.apiService.createVendor(
                              businessName: businessName,
                              cityId: cityId,
                              primaryCategoryId: catId,
                              legalName: legalName,
                              gstNumber: gst,
                              description: desc,
                              ratingAvg: 0.0,
                              verified: false,
                            );

                      if (!mounted) return;
                      setState(() => _submitting = false);

                      if (resp.success) {
                        final successMsg = isUpdating ? 'Vendor updated' : 'Vendor created';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message.isNotEmpty ? resp.message : successMsg)));
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => VendorProfileScreen(apiService: widget.apiService)),
                        );
                      } else {
                        final errMsg = isUpdating ? 'Failed to update vendor' : 'Failed to create vendor';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message.isNotEmpty ? resp.message : errMsg)));
                      }
                    },
              icon: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline),
              label: Text(_submitting ? 'Submitting...' : (v != null ? 'Update Vendor' : 'Create Vendor')),
            ),
          ),
        ],
      ),
    );
  }
}
