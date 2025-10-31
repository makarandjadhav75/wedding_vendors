// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:wedding_market/Screens/Home%20Screen/review_section.dart';
import '../../APiServices/api_services.dart';
import '../../APiServices/common_repo.dart';
import '../../Models/categery_model.dart';
import '../../Models/page_data_Model.dart';
import '../category/category_listing_screen.dart';
import 'category_tile.dart';
import 'help_section.dart';
import 'hero_section.dart';
import 'inspiration_section.dart';
import '../vendor_profile.dart';


class HomeScreen extends StatefulWidget {
  final ApiService apiService;
  final bool isVendor;

  const HomeScreen({Key? key, required this.apiService, this.isVendor = false}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  bool _loading = true;
  String _error = '';

  // vendor stats placeholder
  int _totalBookings = 0;
  double _earnings = 0.0;
  int _newEnquiries = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() {
      _loading = true;
      _error = '';
      _statsLoading = true;
    });

    try {
      final CommonResponse<PagedData<Category>> resp =
      await widget.apiService.
      getCategories(page: 0, size: 10);

      if (resp.success && resp.data != null) {
        setState(() {
          _categories = resp.data!.content;
        });
      } else {
        setState(() {
          _error = resp.message.isNotEmpty ? resp.message : 'Failed to load categories';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
      });
    } finally {
      setState(() => _loading = false);
    }

    await _loadVendorStats();
  }

  Future<void> _loadVendorStats() async {
    setState(() => _statsLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _totalBookings = 12;
        _earnings = 18450.75;
        _newEnquiries = 3;
      });
    } catch (_) {
      // keep defaults
    } finally {
      setState(() => _statsLoading = false);
    }
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text('Error: $_error'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HeroSection(
            onSearchSubmitted: (q) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search for "$q" (not implemented)'))),
            onFindVendors: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Find vendors (not implemented)'))),
          ),
          const SizedBox(height: 16),
          // if (widget.isVendor) ...[
          //   VendorDashboard(
          //     totalBookings: _totalBookings,
          //     earnings: _earnings,
          //     newEnquiries: _newEnquiries,
          //     statsLoading: _statsLoading,
          //     onManageCategories: () {
          //       // Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategeryScreen(apiService: widget.apiService, isVendor: true)));
          //     },
          //   ),
          //   const SizedBox(height: 16),
          // ],
          Align(
            alignment: Alignment.centerLeft,
            child: Row(children: const [Icon(Icons.grid_view, color: Colors.pinkAccent), SizedBox(width: 8), Text('Vendor categories', style: TextStyle(fontWeight: FontWeight.bold))]),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: _categories.isEmpty
                ? const Center(child: Text('No categories'))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final c = _categories[index];
                return CategoryTile(
                  category: c,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CategoryListingScreen(apiService: widget.apiService, category: c, isVendor: widget.isVendor),
                    ));
                  },

                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const ReviewSection(),
          const SizedBox(height: 18),
          const ContactQuickForm(),
          const SizedBox(height: 18),
          const InspirationSection(),
          const SizedBox(height: 24),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.pink), child: const Icon(Icons.favorite, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          const Text('Wedding', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20), // add space on the right side
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VendorProfileScreen(apiService: widget.apiService),
                  ),
                );
              },
              icon: const Icon(Icons.person),
            ),
          ),
        ],

      ),
      body: _buildBody(),
    );
  }
}
