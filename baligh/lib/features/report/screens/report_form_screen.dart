import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/category_card.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'electricity', 'label': 'Electricity', 'icon': Icons.bolt},
    {'id': 'road', 'label': 'Roads', 'icon': Icons.directions_car},
    {'id': 'flood', 'label': 'Floods', 'icon': Icons.water},
    {'id': 'security', 'label': 'Security', 'icon': Icons.security},
    {'id': 'water', 'label': 'Water', 'icon': Icons.opacity},
    {'id': 'health', 'label': 'Health', 'icon': Icons.health_and_safety},
    {'id': 'internet', 'label': 'Internet', 'icon': Icons.wifi},
    {'id': 'market', 'label': 'Market', 'icon': Icons.store},
    {'id': 'government', 'label': 'Admin', 'icon': Icons.account_balance},
    {'id': 'fire', 'label': 'Fire', 'icon': Icons.local_fire_department},
    {'id': 'infrastructure', 'label': 'Infrastructure', 'icon': Icons.construction},
    {'id': 'fraud', 'label': 'Fraud', 'icon': Icons.report_problem},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File a Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'What do you want to report?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return CategoryCard(
                  icon: cat['icon'],
                  label: cat['label'],
                  isSelected: _selectedCategory == cat['id'],
                  onTap: () => setState(() => _selectedCategory = cat['id']),
                );
              },
            ),
            const SizedBox(height: 32),
            const AppTextField(
              label: 'Description',
              hint: 'Provide more details about the issue...',
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {}, // Image Picker Logic
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Upload Photo', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => context.push('/map-picker'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(child: Text('Pick location on map')),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            AppButton(
              text: 'Submit Report',
              onPressed: () {
                if (_selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
