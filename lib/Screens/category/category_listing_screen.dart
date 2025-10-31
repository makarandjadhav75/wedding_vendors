// lib/screens/category_listing_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wedding_market/APiServices/api_services.dart';
import 'package:wedding_market/Models/categery_model.dart';
import 'package:wedding_market/Models/vendor_model.dart';
import 'package:wedding_market/Screens/category/vendor_details.dart';

import '../../APiServices/api_services.dart';

class CategoryListingScreen extends StatefulWidget {
  final ApiService apiService;
  final Category category; // must have `id` and `name`
  final bool isVendor;

  const CategoryListingScreen({
    super.key,
    required this.apiService,
    required this.category,
    required this.isVendor,
  });

  @override
  State<CategoryListingScreen> createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  final List<Vendor> _vendors = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 0;
  final int _size = 20;
  final ScrollController _scrollController = ScrollController();
  String _search = '';
  int _activeFilter = 0;
  bool _useGrid = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchVendors();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loading || _loadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchVendors(loadMore: true);
    }
  }

  int? _resolveCategoryId() {
    final raw = widget.category.id;
    if (raw == null) return null;
    if (raw is int) return raw;
  }

  Future<void> _fetchVendors({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _loadingMore = true);
      _page++;
    } else {
      setState(() {
        _loading = true;
        _error = null;
        _page = 0;
        _vendors.clear();
        _hasMore = true;
      });
    }

    try {
      final int? catId = _resolveCategoryId();

      final resp = await widget.apiService.getVendors(
        page: _page,
        size: _size,
        categoryId: catId,
      );

      if (!mounted) return;

      if (!resp.success || resp.data == null) {
        setState(() {
          _error = resp.message ?? 'Failed to load vendors';
          _loading = false;
          _loadingMore = false;
        });
        return;
      }

      // Expect resp.data!.content to be List<Vendor> (typed). Be defensive.
      final dynamic rawContent = (resp.data as dynamic).content;
      final List<Vendor> parsed = <Vendor>[];

      if (rawContent is List<Vendor>) {
        parsed.addAll(rawContent);
      } else if (rawContent is List) {
        for (final e in rawContent) {
          if (e is Vendor) {
            parsed.add(e);
          } else if (e is Map<String, dynamic>) {
            parsed.add(Vendor.fromJson(e));
          } else {
            // skip unknown entry
          }
        }
      }

      setState(() {
        if (loadMore) {
          _vendors.addAll(parsed);
        } else {
          _vendors
            ..clear()
            ..addAll(parsed);
        }

        // Use server 'last' flag if available; otherwise infer by page size
        final bool isLast =
            (resp.data as dynamic).last == true || parsed.length < _size;
        _hasMore = !isLast;
        _loading = false;
        _loadingMore = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _error = 'Request timed out';
        _loading = false;
        _loadingMore = false;
      });
    } catch (e, st) {
      print('fetchVendors error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchVendors();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category.name ?? 'Vendors';
    final Color accent = Colors.pinkAccent;

    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF7F9),
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _vendors.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF7F9),
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
              const SizedBox(height: 12),
              Text('Error: $_error'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchVendors, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final filtered = _vendors.where((v) {
      if (_search.trim().isEmpty) return true;
      final q = _search.toLowerCase();
      final name = v.ownerFullName.toLowerCase();
      final desc = (v.description ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();

    if (_activeFilter == 1) {
      filtered.sort((a, b) => (b.ratingAvg ?? 0).compareTo(a.ratingAvg ?? 0));
    } else if (_activeFilter == 2) {
      filtered.sort((a, b) => a.ownerFullName.compareTo(b.ownerFullName));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(_useGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _useGrid = !_useGrid),
            tooltip: _useGrid ? 'List view' : 'Grid view',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accent.withOpacity(.15), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent.withOpacity(.1)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withOpacity(.2)),
                            child: const Icon(Icons.local_mall, color: Colors.pink),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('${_vendors.length} vendors', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText: 'Search vendors... ',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accent)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _activeFilter == 0,
                            onTap: () => setState(() => _activeFilter = 0),
                          ),
                          _FilterChip(
                            label: 'Top rated',
                            selected: _activeFilter == 1,
                            onTap: () => setState(() => _activeFilter = 1),
                          ),
                          _FilterChip(
                            label: 'A-Z',
                            selected: _activeFilter == 2,
                            onTap: () => setState(() => _activeFilter = 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No vendors found'),
                    ],
                  ),
                ),
              )
            else if (_useGrid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final v = filtered[index];
                      return _VendorCard(vendor: v, onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => VendorDetailScreen(vendor: v)),
                        );
                      });
                    },
                    childCount: filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .78,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final v = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: _VendorTile(vendor: v, onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => VendorDetailScreen(vendor: v)),
                        );
                      }),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            SliverToBoxAdapter(
              child: Visibility(
                visible: _loadingMore,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.pinkAccent : Colors.grey.shade300;
    final textColor = selected ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;

  const _VendorCard({required this.vendor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pinkAccent.withOpacity(.08)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16/10,
                child: vendor.imageUrl != null && vendor.imageUrl!.isNotEmpty
                    ? Image.network(
                        vendor.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image)),
                      )
                    : Container(color: Colors.grey.shade200, child: const Icon(Icons.store)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.ownerFullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (vendor.ratingAvg != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(vendor.ratingAvg!.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (vendor.description != null && vendor.description!.isNotEmpty)
                    Text(
                      vendor.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.2),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorTile extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;

  const _VendorTile({required this.vendor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: vendor.imageUrl != null && vendor.imageUrl!.isNotEmpty
              ? Image.network(
                  vendor.imageUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                )
              : Container(width: 64, height: 64, color: Colors.grey.shade200, child: const Icon(Icons.store)),
        ),
        title: Text(vendor.ownerFullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vendor.description != null && vendor.description!.isNotEmpty)
              Text(vendor.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (vendor.ratingAvg != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(vendor.ratingAvg!.toStringAsFixed(1)),
                ],
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
