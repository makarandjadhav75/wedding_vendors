import 'package:flutter/material.dart';
import 'package:wedding_market/Models/vendor_model.dart';

class VendorDetailScreen extends StatelessWidget {
  final Vendor vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vendor.ownerFullName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Vendor Image ---
            if (vendor.imageUrl != null && vendor.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  vendor.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store, size: 60, color: Colors.grey),
              ),

            const SizedBox(height: 20),

            // --- Basic Info ---
            Text(
              vendor.ownerFullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vendor ID: ${vendor.vendorId}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // --- Rating + Price ---
            if (vendor.ratingAvg != null || vendor.gstNumber != null)
              Row(
                children: [
                  if (vendor.ratingAvg != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          vendor.ratingAvg!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  if (vendor.ratingAvg != null && vendor.gstNumber != null)
                    const SizedBox(width: 24),
                  if (vendor.gstNumber != null)
                    Text(
                      'Starting from ₹${vendor.gstNumber!.toString()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                ],
              ),

            const SizedBox(height: 20),

            // --- Description ---
            Text(
              'About Vendor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vendor.description?.trim().isNotEmpty == true
                  ? vendor.description!
                  : 'No description available.',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              vendor.ownerFullName?.trim().isNotEmpty == true
                  ? vendor.ownerFullName!
                  : 'Name',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 40),

            // --- Action Button ---
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact feature coming soon')),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('Contact Vendor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
